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
    var output: Output!
    
    
    struct Input {
        let refreshTrigger: AnyObserver<String>
        let loadDataTrigger: AnyObserver<Void>
        let launchDetailTrigger: AnyObserver<Void>
    }
    
    struct Output {
        // let feedsCells: Driver<[ICellConfigurator]>
        let items: Driver<[String]>
        let launchDetail: Driver<Void>
    }
    
    let navigator: MerayakanNavigator
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    
    private let refreshSubject = PublishSubject<String>()
    private let nextSubject = PublishSubject<Void>()
    private let loadDataSubject = PublishSubject<Void>()
    private let launcDetailTrigger = PublishSubject<Void>()
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    private var searchQuery: String?
    private let disposeBag = DisposeBag()
    
    
    init(navigator: MerayakanNavigator, searchTrigger: PublishSubject<String>? = nil, showTableHeader: Bool) {
        self.navigator = navigator
    
        input = Input(
            refreshTrigger: refreshSubject.asObserver(),
            loadDataTrigger: loadDataSubject.asObserver(),
            launchDetailTrigger: launcDetailTrigger.asObserver()
        )
        
        let items = loadDataSubject
            .do(onNext: { (_) in
                print("clicked")
            })
            .map { (_) -> [String] in
                return ["a", "b", "c"]
            }
            .asDriver(onErrorJustReturn: [])
        
        let launcDetail = launcDetailTrigger
            .flatMap({ _ in navigator.launchDetail() })
            .asDriverOnErrorJustComplete()
        
        
        searchTrigger?.asObserver()
            .do(onNext: { [unowned self](query) in
                self.searchQuery = query
            })
            .bind(to: input.refreshTrigger)
            .disposed(by: disposeBag)
        
        let feedsItems = refreshSubject.startWith("")
            .flatMapLatest { [unowned self] (query) -> Observable<[Feeds]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), filter: self.filterItems.first?.paramValue ?? "team_all", query: self.searchQuery ?? query)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
//        let feedsCells = feedsItems
//            .map { (list) -> [ICellConfigurator] in
//                return list.map({ (feeds) -> ICellConfigurator in
//                    return RekapCellConfigured(item: RekapViewCell.Input(viewModel: self, feeds: feeds))
//                })
//        }
        
        
        
        output = Output(
            // feedsCells: feedsCells
            items: items
            
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
