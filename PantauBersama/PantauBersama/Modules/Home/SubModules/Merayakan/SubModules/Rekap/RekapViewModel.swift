//
//  RekapViewModel.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class RekapViewModel: ViewModelType {
    
    var input: Input
    var output: Output

    private let refreshSubject = PublishSubject<String>()
    private let nextSubject = PublishSubject<Void>()
    
    struct Input {
        let refreshTrigger: AnyObserver<String>
    }
    
    struct Output {
        let feedsCells: Driver<[ICellConfigurator]>
//        let moreSelected: Driver<Feeds>
    }
    
    let navigator: MerayakanNavigator
    
    init(navigator: MerayakanNavigator, searchTrigger: PublishSubject<String>? = nil, showTableHeader: Bool) {
        self.navigator = navigator
    
        input = Input(
            refreshTrigger: refreshSubject.asObserver()
        )
        
        let feedsItems = refreshSubject.startWith("")
            .flatMapLatest { [unowned self] (query) -> Observable<[Feeds]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), filter: self.filterItems.first?.paramValue ?? "team_all", query: self.searchQuery ?? query)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        let feedsCells = feedsItems
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (feeds) -> ICellConfigurator in
                    return LinimasaCellConfigured(item: LinimasaCell.Input(viewModel: self, feeds: feeds))
                })
        }
        output = Output(
            feedsCells: feedsCells
        )
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>,
        filter: String,
        query: String) -> Observable<[Feeds]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, filter: filter, query: query)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        filter: String,
        query: String) ->
        Observable<Page<[Feeds]>> {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getFeeds(filter: filter, page: batch.page, perPage: batch.limit, query: query),
                               c: BaseResponse<FeedsResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[Feeds]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, filter: filter, query: query)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transformToPage(response: BaseResponse<FeedsResponse>, batch: Batch) -> Page<[Feeds]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[Feeds]>(
            item: response.data.feeds,
            batch: nextBatch
        )
    }
}
