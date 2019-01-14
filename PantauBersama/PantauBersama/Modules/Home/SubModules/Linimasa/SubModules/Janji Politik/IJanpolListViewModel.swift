//
//  IJanpolListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Networking
import Common

enum JanpolPageType {
    case allJanpol
    case myJanpol
}

protocol IJanpolListViewModelInput {
    var refreshI: AnyObserver<Void> { get }
    var nextPageI: AnyObserver<Void> { get }
    var shareJanjiI: AnyObserver<Any> { get }
    var moreI: AnyObserver<JanjiPolitik> { get }
    var moreMenuI: AnyObserver<JanjiType> { get }
    var itemSelectedI: AnyObserver<IndexPath> { get }
    var filterI: AnyObserver<[PenpolFilterModel.FilterItem]> {get}
}

protocol IJanpolListViewModelOutput {
    var items: Driver<[ICellConfigurator]>! { get }
    var error: Driver<Error>! { get }
    var moreSelectedO: Driver<JanjiPolitik>! { get }
    var moreMenuSelectedO: Driver<Void>! { get }
    var itemSelectedO: Driver<Void>! { get }
    var shareSelectedO: Driver<Void>! { get }
    var filterO: Driver<Void>! { get }
    var bannerO: Driver<BannerInfo>! { get }
    var bannerSelectedO: Driver<Void>! { get }
    var showHeaderO: Driver<Bool>! { get }
}

protocol IJanpolListViewModel {
    var input: IJanpolListViewModelInput { get }
    var output: IJanpolListViewModelOutput { get }
    
    var errorTracker: ErrorTracker { get }
    var activityIndicator: ActivityIndicator { get }
    var headerViewModel: BannerHeaderViewModel { get }
    
    func transformToPage(response: BaseResponse<JanjiPolitikResponse>, batch: Batch) -> Page<[JanjiPolitik]>
    func paginateItems(batch: Batch, nextBatchTrigger: Observable<Void>, cid: String, filter: String) -> Observable<[JanjiPolitik]>
    func recursivelyPaginateItems(batch: Batch, nextBatchTrigger: Observable<Void>, cid: String, filter: String) -> Observable<Page<[JanjiPolitik]>>
}

extension IJanpolListViewModel {
    
    func transformToPage(response: BaseResponse<JanjiPolitikResponse>, batch: Batch) -> Page<[JanjiPolitik]> {
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
    
    func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, cid: String, filter: String) -> Observable<[JanjiPolitik]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, cid: cid, filter: filter)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    func delete(id: String) -> Observable<InfoResponse> {
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
