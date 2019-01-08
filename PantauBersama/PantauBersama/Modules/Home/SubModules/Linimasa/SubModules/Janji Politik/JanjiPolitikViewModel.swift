//
//  JanjiPolitikViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class JanjiPolitikViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshTrigger: AnyObserver<Void>
        let moreTrigger: AnyObserver<JanjiPolitik>
        let moreMenuTrigger: AnyObserver<JanjiType>
        let shareJanji: AnyObserver<Any>
        let nextTrigger: AnyObserver<Void>
        let viewWillAppearTrigger: AnyObserver<Void>
        var itemSelectedTrigger: AnyObserver<IndexPath>
        let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
    }
    
    struct Output {
        let janpolCells: Driver<[ICellConfigurator]>
        let moreSelected: Driver<JanjiPolitik>
        let moreMenuSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let bannerInfo: Driver<BannerInfo>
        let infoSelected: Driver<Void>
        let itemSelected: Driver<Void>
        let filter: Driver<Void>
    }
    
    private let refreshSubject = PublishSubject<Void>()
    private let moreSubject = PublishSubject<JanjiPolitik>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<Any>()
    private let nextSubject = PublishSubject<Void>()
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    
    private let navigator: JanjiPolitikNavigator
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        input = Input(refreshTrigger: refreshSubject.asObserver(),
                      moreTrigger: moreSubject.asObserver(),
                      moreMenuTrigger: moreMenuSubject.asObserver(),
                      shareJanji: shareSubject.asObserver(),
                      nextTrigger: nextSubject.asObserver(),
                      viewWillAppearTrigger: viewWillAppearSubject.asObserver(),
                      itemSelectedTrigger: itemSelectedSubject.asObserver(),
                      filterTrigger: filterSubject.asObserver())
        
        let bannerInfo = viewWillAppearSubject
            .flatMapLatest({ self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        // MARK:
        // Get janji politik pagination
        let janpolItems = Observable.combineLatest(viewWillAppearSubject, refreshSubject.startWith(()))
            .flatMapLatest { [unowned self] (_) -> Observable<[JanjiPolitik]> in
               
                let cid = self.filterItems.filter({ $0.paramKey == "cluster_id"}).first?.paramValue
                let filter = self.filterItems.filter({ $0.paramKey == "filter_by"}).first?.paramValue
                
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), cid: cid ?? "", filter: filter ?? "")
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriver(onErrorJustReturn: [])
        
        // MARK:
        // Map feeds response to cell list
        let janpolCells = janpolItems
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (janpol) -> ICellConfigurator in
                    return LinimasaJanjiCellConfigured(item: LinimasaJanjiCell.Input(viewModel: self, janpol: janpol))
                })
        }
        
        let moreSelected = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let shareJanji = shareSubject
            .flatMapLatest({ _ in navigator.shareJanji(data: "Any") })
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest { (type) -> Observable<Void> in
                switch type {
                case .bagikan:
                    return navigator.shareJanji(data: "as")
                case .salin:
                    return navigator.sharePilpres(data: "sa")
                case .hapus(let id):
                    return self.delete(id: id).mapToVoid()
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedSubject
            .withLatestFrom(janpolItems) { (indexPath, items) -> JanjiPolitik in
                return items[indexPath.row]
            }
            .flatMapLatest({ navigator.launchJanjiDetail(data: $0) })
            .asDriverOnErrorJustComplete()
        
        let filter = filterSubject
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                self.filterItems = filterItems
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        output = Output(janpolCells: janpolCells,
                        moreSelected: moreSelected,
                        moreMenuSelected: moreMenuSelected,
                        shareSelected: shareJanji,
                        bannerInfo: bannerInfo,
                        infoSelected: infoSelected,
                        itemSelected: itemSelected,
                        filter: filter)
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, cid: String, filter: String) -> Observable<[JanjiPolitik]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, cid: cid, filter: filter)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, cid: String, filter: String) ->
        Observable<Page<[JanjiPolitik]>> {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getJanjiPolitiks(cid: cid, filter: filter, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<JanjiPolitikResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[JanjiPolitik]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, cid: cid, filter: filter)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transformToPage(response: BaseResponse<JanjiPolitikResponse>, batch: Batch) -> Page<[JanjiPolitik]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[JanjiPolitik]>(
            item: response.data.janjiPolitiks,
            batch: nextBatch
        )
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "janji politik"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
    private func delete(id: String) -> Observable<InfoResponse> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.deleteJanjiPolitiks(id: id),
                c: InfoResponse.self)
            .asObservable()
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .catchErrorJustComplete()
    }
    
}
