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
        let shareI: AnyObserver<String>
    }
    
    struct Output {
        let badgeItems: Driver<[ICellConfigurator]>
        let error: Driver<Error>
        let loading: Driver<Bool>
        let shareO: Driver<Void>
        let backO: Driver<Void>
    }
    
    private let navigator: BadgeNavigator!
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let nextS = PublishSubject<Void>()
    private let shareS = PublishSubject<String>()
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: BadgeNavigator, userId: String?) {
        self.navigator = navigator
        
        input = Input(refreshI: refreshS.asObserver(),
                      backI: backS.asObserver(),
                      nextTrigger: nextS.asObserver(),
                      shareI: shareS.asObserver()
        )
        let myId = AppState.local()?.user.id
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
        // MARK
        // Get All Badge User
        let itemsUser = refreshS.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[ICellConfigurator]> in
                return self.paginateItemsUser(nextBatchTrigger: self.nextS.asObservable(), userId: userId ?? "")
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        let share = shareS
            .flatMapLatest({ navigator.launchShare(id: $0) })
            .asDriverOnErrorJustComplete()
        
        let back = backS
            .do(onNext: { (_) in
                navigator.back()
            })
            .asDriverOnErrorJustComplete()
        
        var state: Bool = false
        if userId != myId {
            state = false
        } else {
            state = true
        }

        output = Output(badgeItems: state ? items : itemsUser,
                        error: errorTracker.asDriver(),
                        loading: activityIndicator.asDriver(),
                        shareO: share,
                        backO: back)
    }
    
    
    private func transformToPage(response: BaseResponse<BadgesResponse>, batch: Batch, isMyAccount: Bool) -> Page<[ICellConfigurator]> {
        var items: [[ICellConfigurator]] = [[]]
        let list = response.data.badges
            .map { (badge) -> ICellConfigurator in
                return BadgeCellConfigured.init(item: BadgeCell.Input(badges: badge, isAchieved: false, viewModel: self, idAchieved: nil, isMyAccount: isMyAccount))
        }
        let achieved = response.data.achieved
            .map { (badge) -> ICellConfigurator in
                return BadgeCellConfigured.init(item: BadgeCell.Input(badges: badge.badge, isAchieved: true, viewModel: self, idAchieved: badge.id, isMyAccount: isMyAccount))
        }
        items.append(achieved)
        items.append(list)
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ICellConfigurator]>(
            item: items.flatMap({ $0 }),
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
            .map({ self.transformToPage(response: $0, batch: batch, isMyAccount: true) })
            .do(onSuccess: { (r) in
                
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .asObservable()
            .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                return result.batch.next().hasNextPage
            }, nextPageFactory: { (result) -> Observable<Page<[ICellConfigurator]>> in
                self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger)
            })
            .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func paginateItemsUser(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, userId: String) -> Observable<[ICellConfigurator]> {
        return recursivelyPaginateItemsUser(batch: batch, nextBatchTrigger: nextBatchTrigger, userId: userId)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItemsUser(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, userId: String) ->
        Observable<Page<[ICellConfigurator]>> {
            return NetworkService.instance
                .requestObject(PantauAuthAPI.getUserBadges(id: userId, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<BadgesResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch, isMyAccount: false) })
                .do(onSuccess: { (r) in
                    
                }, onError: { (e) in
                    print(e.localizedDescription)
                })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[ICellConfigurator]>> in
                    self.recursivelyPaginateItemsUser(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, userId: userId)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
}
