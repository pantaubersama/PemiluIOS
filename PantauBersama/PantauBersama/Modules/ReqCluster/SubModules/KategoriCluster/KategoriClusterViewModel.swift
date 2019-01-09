//
//  KategoriClusterViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

enum CategoriesResult {
    case done(categories: ClusterCategory)
}

class KategoriClusterViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let queryI: AnyObserver<String>
        let nextI: AnyObserver<Void>
        let addI: AnyObserver<Void>
        let refreshI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<String>
        let itemSelectedI: AnyObserver<IndexPath>
    }
    
    struct Output {
        let itemsO: Driver<[String]>
        let addO: Driver<Void>
        let resultO: Driver<CategoriesResult>
    }
    
    private let backS = PublishSubject<Void>()
    private var navigator: KategoriClusterProtocol
    private let queryS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    private let addS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<String>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: KategoriClusterProtocol) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      queryI: queryS.asObserver(),
                      nextI: nextS.asObserver(),
                      addI: addS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      itemSelectedI: itemSelectedS.asObserver())
        
        let query = queryS
            .startWith((""))
        
        let refreshWithLatestQuery = refreshS
            .withLatestFrom(query)
        
        let categories = Observable.merge(query, refreshWithLatestQuery, viewWillAppearS.asObservable())
            .flatMapLatest { [weak self] (s) -> Observable<[ClusterCategory]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), q: s)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        let categoiesCell = categories
            .map { (list) -> [String] in
                return list.map({ (categories) -> String in
                    return categories.name
                })
        }
        
        let add = addS
            .flatMapLatest({ navigator.launchAdd() })
            .asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedS
            .withLatestFrom(categories) { (indexPath, items) in
                return items[indexPath.row]
            }
            .map({ CategoriesResult.done(categories: $0)})
            .asDriverOnErrorJustComplete()
        
        
        output = Output(itemsO: categoiesCell.asDriver(onErrorJustReturn: []),
                        addO: add,
                        resultO: itemSelected)
        
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, q: String) -> Observable<[ClusterCategory]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, q: q)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, q: String) ->
        Observable<Page<[ClusterCategory]>> {
            return NetworkService.instance
                .requestObject(PantauAuthAPI.categories(q: q, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<CategoriesResponse>.self)
                .map({ self.transfromToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[ClusterCategory]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, q: q)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transfromToPage(response: BaseResponse<CategoriesResponse>, batch: Batch) -> Page<[ClusterCategory]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ClusterCategory]>(
        item: response.data.categories,
        batch: nextBatch)
        
    }
}
