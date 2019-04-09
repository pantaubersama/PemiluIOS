//
//  RekapListTPSViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

final class RekapListTPSViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
        let nextI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
    }
    
    struct Output {
        let backO: Driver<Void>
        let itemsO: Driver<[RealCount]>
        let titleO: Driver<String>
        let itemSelectedO: Driver<Void>
    }
    
    private let navigator: RekapListTPSNavigator
    private let villageId: Int
    private let villageName: String
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let backS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    
    init(navigator: RekapListTPSNavigator, villageId: Int, villageName: String) {
        self.navigator = navigator
        self.villageId = villageId
        self.villageName = villageName
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      nextI: nextS.asObserver(),
                      itemSelectedI: itemSelectedS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let items = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[RealCount]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), userId: nil, villageCode: "\(villageId)", dapilId: nil)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
        }
        
        /// Item Selected
        let itemSelected = itemSelectedS
            .withLatestFrom(items) { indexPath, model in
                return model[indexPath.row]
            }
            .flatMapLatest({ navigator.launchDetailTPSUser(realCount: $0)})
            .asDriverOnErrorJustComplete()
        
        
        
        output = Output(backO: back,
                        itemsO: items.asDriverOnErrorJustComplete(),
                        titleO: Driver.just(self.villageName),
                        itemSelectedO: itemSelected)
        
    }
    
}

extension RekapListTPSViewModel {
    
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
}
