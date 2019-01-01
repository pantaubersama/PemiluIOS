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
    }
    
    struct Output {
        let janpolCells: Driver<[ICellConfigurator]>
        let moreSelected: Driver<JanjiPolitik>
        let moreMenuSelected: Driver<Void>
        let shareSelected: Driver<Void>
    }
    
    private let refreshSubject = PublishSubject<Void>()
    private let moreSubject = PublishSubject<JanjiPolitik>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<Any>()
    private let nextSubject = PublishSubject<Void>()
    
    private let navigator: JanjiPolitikNavigator
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        input = Input(refreshTrigger: refreshSubject.asObserver(),
                      moreTrigger: moreSubject.asObserver(),
                      moreMenuTrigger: moreMenuSubject.asObserver(),
                      shareJanji: shareSubject.asObserver(),
                      nextTrigger: nextSubject.asObserver())
        
        // MARK:
        // Get janji politik pagination
        let janpolItems = refreshSubject.startWith(())
            .flatMapLatest { [unowned self] (_) -> Observable<[JanjiPolitik]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable())
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
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        output = Output(janpolCells: janpolCells,
                        moreSelected: moreSelected,
                        moreMenuSelected: moreMenuSelected,
                        shareSelected: shareJanji)
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>) -> Observable<[JanjiPolitik]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>) ->
        Observable<Page<[JanjiPolitik]>> {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getJanjiPolitiks(page: batch.page, perPage: batch.limit),
                               c: BaseResponse<JanjiPolitikResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[JanjiPolitik]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger)
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
    
}
