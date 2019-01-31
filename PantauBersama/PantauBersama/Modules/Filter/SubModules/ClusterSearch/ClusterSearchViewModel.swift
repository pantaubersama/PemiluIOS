//
//  ClusterSearchViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

enum ClusterResult {
    case cancel
    case done(cluster: ClusterDetail)
}


final class ClusterSearchViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let itemSelected: AnyObserver<IndexPath>
        let refreshI: AnyObserver<String>
        let query: AnyObserver<String>
        let nextI: AnyObserver<Void>
        let filterI: AnyObserver<[PenpolFilterModel.FilterItem]>
    }
    
    struct Output {
        let items: Driver<[ICellConfigurator]>
        let selected: Driver<Void>
        let filter: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private var queryS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    private let filterS = PublishSubject<[PenpolFilterModel.FilterItem]>()
    private let refreshS = PublishSubject<String>()
    
    private var searchQuery: String?
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    var delegate: IClusterSearchDelegate!
    
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    private let disposeBag = DisposeBag()
    init(searchTrigger: PublishSubject<String>? = nil, navigator: ClusterSearchNavigator? = nil, clearFilter: Bool = false) {
        input = Input(backI: backS.asObserver(),
                      itemSelected: itemSelectedS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      query: queryS.asObserver(),
                      nextI: nextS.asObserver(),
                      filterI: filterS.asObserver())
        
        if !clearFilter {
            let cachedFilter = PenpolFilterModel.generateClusterFilter()
            cachedFilter.forEach { (filterModel) in
                let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                    return filterItem.isSelected || filterItem.type == .text
                })
                self.filterItems.append(contentsOf: selectedItem)
            }
        }
        
        
        if let externalQuery = searchTrigger {
            self.queryS = externalQuery
        }
        
        queryS.asObserver()
            .do(onNext: { [unowned self](query) in
                self.searchQuery = query
            })
            .bind(to: refreshS)
            .disposed(by: disposeBag)
        
        let cluster = refreshS.startWith("")
            .flatMapLatest { [weak self] (s) -> Observable<[ClusterDetail]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), q: self.searchQuery ?? s)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        let clusterCell = cluster
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (cluster) -> ICellConfigurator in
                    return ClusterSearchCellConfigured(item: ClusterSearchCell.Input(data: cluster))
                })
        }.asDriver(onErrorJustReturn: [])
        
        let clusterEligibleCell = cluster
            .map { (list) -> [ICellConfigurator] in
                return list.filter({ $0.isEligible == true }).map({ (cluster) -> ICellConfigurator in
                    return ClusterSearchCellConfigured(item: ClusterSearchCell.Input(data: cluster))
                })
            }.asDriver(onErrorJustReturn: [])
        
        var itemSelected = itemSelectedS
            .withLatestFrom(cluster) { (indexPath, items) -> Observable<Void> in
                let items = items[indexPath.row]
                return self.delegate.didSelectCluster(item: items, index: indexPath)
            }
//            .flatMapLatest({ self.delegate.didSelectCluster(item: $0)})
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        if let searchNavigator = navigator {
            itemSelected = itemSelectedS
                .withLatestFrom(cluster) { (indexPath, items) -> ClusterDetail in
                    return items[indexPath.row]
                }
                .do(onNext: { (clusterDetail) in
                    print("select cluster \(clusterDetail)")
                })
                .flatMapLatest({ searchNavigator.lunchClusterDetail(cluster: $0) })
                .asDriverOnErrorJustComplete()
        }
        
        let filterO = filterS
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("cluster-categories")
                })
                
                self.filterItems = filter
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        output = Output(items: (navigator != nil) ? clusterCell : clusterEligibleCell,
                        selected: itemSelected,
                        filter: filterO)
        
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, q: String) -> Observable<[ClusterDetail]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, q: q)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, q: String) ->
        Observable<Page<[ClusterDetail]>> {
            let categoryId = self.filterItems.filter({ $0.paramKey == "filter_value"}).first?.paramValue ?? ""
            
            return NetworkService.instance
                .requestObject(PantauAuthAPI.clusters(q: q, page: batch.page, perPage: batch.limit, filterValue: categoryId),
                               c: BaseResponse<Clusters>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[ClusterDetail]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, q: q)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transformToPage(response: BaseResponse<Clusters>, batch: Batch) -> Page<[ClusterDetail]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ClusterDetail]>(
            item: response.data.clusters,
            batch: nextBatch
        )
    }
}
