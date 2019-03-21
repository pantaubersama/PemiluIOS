//
//  PerhitunganViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class PerhitunganViewModel: ViewModelType {
    struct Input {
        let refreshTrigger: AnyObserver<Void>
        let createPerhitunganTrigger: AnyObserver<Void>
//        let moreTrigger: AnyObserver<Feeds>
//        let moreMenuTrigger: AnyObserver<PilpresType>
        let nextTrigger: AnyObserver<Void>
        let itemSelectTrigger: AnyObserver<IndexPath>
    }
    
    struct Output {
        let createPerhitunganO: Driver<Void>
        let feedsCells: Driver<[ICellConfigurator]>
        let bannerInfo: Driver<BannerInfo>
        let infoSelected: Driver<Void>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
//        let itemSelected: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    private let navigator: PerhitunganNavigator
    let headerViewModel = BannerHeaderViewModel()
    
    private let refreshSubject = PublishSubject<Void>()
    private let createPerhitunganSubject = PublishSubject<Void>()
//    private let moreSubject = PublishSubject<Feeds>()
//    private let moreMenuSubject = PublishSubject<PilpresType>()
    private let nextSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: PerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input(refreshTrigger: refreshSubject.asObserver(),
                      createPerhitunganTrigger: createPerhitunganSubject.asObserver(),
                      nextTrigger: nextSubject.asObserver(),
                      itemSelectTrigger: itemSelectedSubject.asObserver())
        
        let createPerhitungan = createPerhitunganSubject
            .flatMap({ navigator.launchCreatePerhitungan() })
            .asDriverOnErrorJustComplete()
        
        // MARK:
        // Get feeds pagination
        let feedsItems = refreshSubject.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[RealCount]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), userId: nil, villageCode: nil, dapilId: nil)
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
                    return PerhitunganCellConfigured(item: PerhitunganCell.Input(viewModel: self, data: feeds))
                })
        }
        
        let bannerInfo = refreshSubject.startWith(())
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(createPerhitunganO: createPerhitungan,
                        feedsCells: feedsCells,
                        bannerInfo: bannerInfo,
                        infoSelected: infoSelected,
                        isLoading: activityIndicator.asDriver(),
                        error: errorTracker.asDriver())
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>,
        userId: String?,
        villageCode: String?,
        dapilId: String?) -> Observable<[RealCount]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, userId: userId, villageCode: villageCode,dapilId: dapilId)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        userId: String?,
        villageCode: String?,
        dapilId: String?) ->
        Observable<Page<[RealCount]>> {
            return NetworkService.instance
                .requestObject(HitungAPI.getRealCounts(page: batch.page, perPage: batch.offset, userId: userId, villageCode: villageCode, dapilId: dapilId),
                               c: BaseResponse<RealCountsResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[RealCount]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, userId: userId, villageCode: villageCode, dapilId: dapilId)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transformToPage(response: BaseResponse<RealCountsResponse>, batch: Batch) -> Page<[RealCount]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[RealCount]>(
            item: response.data.realCounts,
            batch: nextBatch
        )
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: BannerPage.perhitungan ),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
}



