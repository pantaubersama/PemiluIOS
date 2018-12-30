//
//  BadgeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import Common
import RxCocoa

class BadgeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshI: AnyObserver<Void>
        let backI: AnyObserver<Void>
        let nextTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let badgeItems: Driver<[ICellConfigurator]>
        let error: Driver<Error>
        let loading: Driver<Bool>
    }
    
    private let navigator: BadgeNavigator!
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let nextS = PublishSubject<Void>()
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: BadgeNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(refreshI: refreshS.asObserver(),
                      backI: backS.asObserver(),
                      nextTrigger: nextS.asObserver())
        
        // MARK
        // Get All Badges, paginate
        let items = refreshS.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[ICellConfigurator]> in
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable())
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .catchErrorJustReturn([])
        }
        .asDriver(onErrorJustReturn: [])
        
        
        output = Output(badgeItems: items,
                        error: errorTracker.asDriver(),
                        loading: activityIndicator.asDriver())
    }
    
    
    private func transformToPage(response: BaseResponse<BadgesResponse>, batch: Batch) -> Page<[ICellConfigurator]> {
        let list = response.data.badges
            .map { (badge) -> ICellConfigurator in
                return BadgeCellConfigured.init(item: BadgeCell.Input(badges: badge))
        }
        
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ICellConfigurator]>(
            item: list,
            batch: nextBatch
        )
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>) -> Observable<[ICellConfigurator]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>) ->
            Observable<Page<[ICellConfigurator]>> {
        return NetworkService.instance
            .requestObject(PantauAuthAPI.badges(page: batch.page, perPage: batch.limit),
                           c: BaseResponse<BadgesResponse>.self)
            .map({ self.transformToPage(response: $0, batch: batch) })
            .asObservable()
            .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                return result.batch.next().hasNextPage
            }, nextPageFactory: { (result) -> Observable<Page<[ICellConfigurator]>> in
                self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger)
            })
            .share(replay: 1, scope: .whileConnected)
            
    }
    
    
    
}
