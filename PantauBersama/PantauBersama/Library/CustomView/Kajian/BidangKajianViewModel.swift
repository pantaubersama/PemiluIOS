//
//  BidangKajianViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Networking

enum BidangKajianResult {
    case cancel
    case ok(id: String)
}


final class BidangKajianViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let cancelI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
        let queryI: AnyObserver<String>
        let refreshI: AnyObserver<Void>
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let itemsO: Driver<[String]>
        let actionSelected: Driver<BidangKajianResult>
    }
    
    private var navigator: BidangKajianNavigator
    private let cancelS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let queryS = PublishSubject<String>()
    private let refreshS = PublishSubject<Void>()
    private let nextS = PublishSubject<Void>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: BidangKajianNavigator) {
        self.navigator = navigator
        
        
        input = Input(cancelI: cancelS.asObserver(),
                      itemSelectedI: itemSelectedS.asObserver(),
                      queryI: queryS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      nextI: nextS.asObserver())
        
        let query = queryS
            .startWith("")
        
        let refreshWithLatestQuery = refreshS
            .withLatestFrom(query)
        
        let tag = Observable.merge(query, refreshWithLatestQuery)
            .flatMapLatest { [weak self] (s) -> Observable<[TagKajian]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), q: s)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
        }
        
        let item = tag
            .map { (list) -> [String] in
                return list.map({ (tag) -> String in
                    return tag.name
                })
        }.asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedS
            .withLatestFrom(tag) { (indexPath, kajian) in
                return kajian[indexPath.row]
            }
            .map({ BidangKajianResult.ok(id: $0.name) })
        
    
        let cancel = cancelS
            .map({ BidangKajianResult.cancel })
        
        
        let action = Observable.merge(itemSelected, cancel)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        
        output = Output(itemsO: item, actionSelected: action)
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, q: String) -> Observable<[TagKajian]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, q: q)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, q: String) ->
        Observable<Page<[TagKajian]>> {
            return NetworkService.instance
                .requestObject(OpiniumServiceAPI.tagKajian(page: batch.page, perPage: batch.limit, q: q),
                               c: BaseResponse<TagKajianResponse>.self)
                .map({ self.transfromToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[TagKajian]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, q: q)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transfromToPage(response: BaseResponse<TagKajianResponse>, batch: Batch) -> Page<[TagKajian]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[TagKajian]>(
            item: response.data.tags,
            batch: nextBatch)
        
    }
    
}
