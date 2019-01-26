//
//  PilpresViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class PilpresViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshTrigger: AnyObserver<String>
        let moreTrigger: AnyObserver<Feeds>
        let moreMenuTrigger: AnyObserver<PilpresType>
        let nextTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
        let itemSelectTrigger: AnyObserver<IndexPath>
    }
    
    struct Output {
        let feedsCells: Driver<[ICellConfigurator]>
        let moreSelected: Driver<Feeds>
        let moreMenuSelected: Driver<String>
        let bannerInfo: Driver<BannerInfo>
        let infoSelected: Driver<Void>
        let filter: Driver<Void>
        let showHeader: Driver<Bool>
        let itemSelected: Driver<Void>
    }
    
    private let refreshSubject = PublishSubject<String>()
    private let moreSubject = PublishSubject<Feeds>()
    private let moreMenuSubject = PublishSubject<PilpresType>()
    private let nextSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    
    private let navigator: PilpresNavigator
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    private var searchQuery: String?
    private let disposeBag = DisposeBag()
    
    init(navigator: LinimasaNavigator, searchTrigger: PublishSubject<String>? = nil, showTableHeader: Bool) {
        self.navigator = navigator
        
        input = Input(
            refreshTrigger: refreshSubject.asObserver(),
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver(),
            nextTrigger: nextSubject.asObserver(),
            filterTrigger: filterSubject.asObserver(),
            itemSelectTrigger: itemSelectedS.asObserver())
        
        let cachedFilter = PenpolFilterModel.generatePilpresFilter()
        cachedFilter.forEach { (filterModel) in
            let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                return filterItem.isSelected
            })
            self.filterItems.append(contentsOf: selectedItem)
        }
        
        let bannerInfo = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        let filter = filterSubject
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("pilpres")
                })
                
                if !filter.isEmpty {
                    self.filterItems = filterItems
                }
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        searchTrigger?.asObserver()
            .do(onNext: { [unowned self](query) in
                self.searchQuery = query
            })
            .bind(to: input.refreshTrigger)
            .disposed(by: disposeBag)
        
        // MARK:
        // Get feeds pagination
        let feedsItems = refreshSubject.startWith("")
            .flatMapLatest { [unowned self] (query) -> Observable<[Feeds]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), filter: self.filterItems.first?.paramValue ?? "team_all", query: self.searchQuery ?? query)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        // MARK:
        // Map feeds response to cell list
        let feedsCells = feedsItems
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (feeds) -> ICellConfigurator in
                    return LinimasaCellConfigured(item: LinimasaCell.Input(viewModel: self, feeds: feeds))
                })
            }
        
        let moreSelected = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
    
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest({ (type) -> Observable<String> in
                switch type {
                case .salin(let feeds):
                    let contentToShare = feeds.source.text
                    return navigator.sharePilpres(data: contentToShare)
                        .map({ (_) -> String in
                            return ""
                        })
                case .bagikan(let feeds):
                    let contentToShare = feeds.source.text
                    return navigator.sharePilpres(data: contentToShare)
                        .map({ (_) -> String in
                            return ""
                        })
                case .twitter(let feeds):
                    let id = feeds.source.id
                    return navigator.openTwitter(data: id)
                        .map({ (_) -> String in
                            return ""
                        })
                }
            })
            .asDriverOnErrorJustComplete()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        let showTableHeader = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        // MARK
        // item selected will launch WKWebView
        let selected = itemSelectedS
            .withLatestFrom(feedsItems) { (indexPath, items) -> Feeds in
                return items[indexPath.row]
            }
            .flatMapLatest({ navigator.launcWebView(
                link: "https://twitter.com/i/web/status/\($0.source.id)")})
            .asDriverOnErrorJustComplete()
        
        
        output = Output(feedsCells: feedsCells,
                        moreSelected: moreSelected,
                        moreMenuSelected: moreMenuSelected,
                        bannerInfo: bannerInfo,
                        infoSelected: infoSelected,
                        filter: filter,
                        showHeader: showTableHeader,
                        itemSelected: selected)
        
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
    
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "pilpres"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
}


