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
        let query: AnyObserver<String>
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let items: Driver<[ICellConfigurator]>
        let selected: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let queryS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    var delegate: IClusterSearchDelegate!
    
    private let disposeBag = DisposeBag()
    init(searchTrigger: PublishSubject<String>? = nil) {
        
        
        input = Input(backI: backS.asObserver(),
                      itemSelected: itemSelectedS.asObserver(),
                      query: queryS.asObserver(),
                      nextI: nextS.asObserver())
        
        
        searchTrigger?.asObserver()
            .bind(to: input.query)
            .disposed(by: disposeBag)
        
        let cluster = queryS.startWith((""))
            .flatMapLatest { [weak self] (s) -> Observable<[ClusterDetail]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), q: s)
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
        }
        
        let itemSelected = itemSelectedS
            .withLatestFrom(cluster) { (indexPath, items) -> Observable<Void> in
                let items = items[indexPath.row]
                return self.delegate.didSelectCluster(item: items, index: indexPath)
            }
//            .flatMapLatest({ self.delegate.didSelectCluster(item: $0)})
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        output = Output(items: clusterCell.asDriver(onErrorJustReturn: []),
                        selected: itemSelected)
        
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
            return NetworkService.instance
                .requestObject(PantauAuthAPI.clusters(q: q, page: batch.page, perPage: batch.limit),
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
