//
//  CatatanPartyViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

class CatatanPartyViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let viewWillAppearI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
        let nextTriggerI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
        let notPreferenceI: AnyObserver<String>
    }
    
    struct Output {
        let itemsO: Driver<[ICellConfigurator]>
        let itemSelectedO: Driver<PoliticalParty>
        let userDataO: Driver<UserResponse>
        let notPreferenceO: Driver<String>
    }
    
    private let viewWillAppearS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let nextS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let notePreferenceS = PublishSubject<String>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init() {
        
        input = Input(
            viewWillAppearI: viewWillAppearS.asObserver(),
            itemSelectedI: itemSelectedS.asObserver(),
            nextTriggerI: nextS.asObserver(),
            refreshI: refreshS.asObserver(),
            notPreferenceI: notePreferenceS.asObserver()
        )
        
        let items = refreshS.startWith("")
            .flatMapLatest { [unowned self] (_) -> Observable<[PoliticalParty]> in
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable())
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
            }
            .asDriverOnErrorJustComplete()
        
        let itemsCell = items
            .map { (list) ->  [ICellConfigurator] in
                return list.map({ (political) -> ICellConfigurator in
                    return PartyCellConfigured(item: PartyCell.Input(data: political))
                })
        }
        
        let selected = itemSelectedS
            .withLatestFrom(items) { (indexPath, item) -> PoliticalParty in
                return item[indexPath.row]
            }
            .asDriverOnErrorJustComplete()
        
        // MARK
        // Get Local user data
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let cloud = NetworkService.instance
            .requestObject(PantauAuthAPI.me,
                           c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                AppState.saveMe(response)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        let userData = viewWillAppearS
            .flatMapLatest({ Observable.merge(local, cloud) })
        
        output = Output(
            itemsO: itemsCell.asDriver(onErrorJustReturn: []),
            itemSelectedO: selected,
            userDataO: userData.asDriverOnErrorJustComplete(),
            notPreferenceO: notePreferenceS.asDriverOnErrorJustComplete()
        )
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>) -> Observable<[PoliticalParty]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>) ->
        Observable<Page<[PoliticalParty]>> {
            return NetworkService.instance
                .requestObject(PantauAuthAPI.politicalParties(page: batch.page, perPage: batch.limit), c: BaseResponse<PoliticalPartyResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[PoliticalParty]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transformToPage(response: BaseResponse<PoliticalPartyResponse>, batch: Batch) -> Page<[PoliticalParty]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[PoliticalParty]>(
            item: response.data.politicalParty,
            batch: nextBatch
        )
    }
}
