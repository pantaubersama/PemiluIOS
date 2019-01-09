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

class KategoriClusterViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let queryI: AnyObserver<String>
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let itemsO: Driver<[String]>
    }
    
    private let backS = PublishSubject<Void>()
    private var navigator: KategoriClusterProtocol
    private let queryS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: KategoriClusterProtocol) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      queryI: queryS.asObserver(),
                      nextI: nextS.asObserver())
        
        let categories = queryS.startWith((""))
            .flatMapLatest { [weak self] (s) -> Observable<[ClusterCategory]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), q: s)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        let clusterCell = categories
            .map { (list) -> [String] in
                return list.map({ (categories) -> String in
                    return categories.name
                })
        }
        
        output = Output(itemsO: clusterCell.asDriver(onErrorJustReturn: []))
        
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
