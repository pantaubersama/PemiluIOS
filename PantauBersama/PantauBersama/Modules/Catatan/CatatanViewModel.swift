//
//  CatatanViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking


class CatatanViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
        let notePreferenceValueI: BehaviorSubject<Int>
        let partyPreferenceValueI: BehaviorSubject<String>
        let updateI: AnyObserver<Void>
    }
    
    struct Output {
        let enableO: Driver<Bool>
        let updateO: Driver<Void>
        let errorTracker: Driver<Error>
        let userDataO: Driver<UserResponse>
        let totalResultO: Driver<TrendResponse>
        let partyItemsO: Driver<[PoliticalParty]>
        let notePreferenceValueO: Driver<Int>
        let partyPreferenceValueO: Driver<String>
    }
    
    private var navigator: CatatanNavigator
    private let backS = PublishSubject<Void>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private let viewWillAppearS = PublishSubject<Void>()
    private let notePreferenceValueS = BehaviorSubject<Int>(value: 0)
    private let partyPreferenceValueS = BehaviorSubject<String>(value: "")
    private let updateS = PublishSubject<Void>()
    private(set) var disposeBag = DisposeBag()
    
    var partyItems = BehaviorRelay<[PoliticalParty]>(value: [])
    
    init(navigator: CatatanNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(
            backI: backS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            notePreferenceValueI: notePreferenceValueS.asObserver(),
            partyPreferenceValueI: partyPreferenceValueS.asObserver(),
            updateI: updateS.asObserver()
        )
        
        let enable = Observable.combineLatest(notePreferenceValueS, partyPreferenceValueS.startWith(""))
            .map { (i,s) -> Bool in
                var state: Bool = false
                if i > 0 || s.count > 0 {
                    state = true
                }
                return state
            }.startWith(false)
            .asDriverOnErrorJustComplete()
        
        let update = updateS
            .withLatestFrom(Observable.combineLatest(
                notePreferenceValueS.asObservable(), partyPreferenceValueS.startWith("")
                ))
            .flatMapLatest { [weak self] (i,s) -> Observable<BaseResponse<UserResponse>> in
                guard let `self` = self else { return Observable.empty() }
                return self.update(vote: i, party: s)
            }
            .mapToVoid()
            .flatMapLatest({ navigator.back() })
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
        
        // MARK
        // GET Total Result
        let totalResult = viewWillAppearS
            .flatMapLatest({ [unowned self] (_) -> Observable<TrendResponse> in
                return NetworkService.instance
                    .requestObject(QuizAPI.getTotalResult(),
                                   c: BaseResponse<TrendResponse>.self)
                    .map({ $0.data })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
            })
            .asDriverOnErrorJustComplete()
        
        // MARK
        // GET List Political Party
        let itemsParty = viewWillAppearS
            .flatMapLatest { [unowned self] (_) -> Observable<[PoliticalParty]> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.politicalParties(page: 1, perPage: 100),
                                   c: BaseResponse<PoliticalPartyResponse>.self)
                    .map({ $0.data.politicalParty })
                    .do(onSuccess: { (items) in
                        self.partyItems.accept(items)
                    })
                    .asObservable()
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustComplete()
            }.asDriverOnErrorJustComplete()
        
        output = Output(enableO: enable,
                        updateO: update,
                        errorTracker: errorTracker.asDriver(),
                        userDataO: userData.asDriverOnErrorJustComplete(),
                        totalResultO: totalResult,
                        partyItemsO: itemsParty,
                        notePreferenceValueO: notePreferenceValueS.asDriverOnErrorJustComplete(),
                        partyPreferenceValueO: partyPreferenceValueS.asDriverOnErrorJustComplete())
    }
    
    private func update(vote: Int, party: String) -> Observable<BaseResponse<UserResponse>> {
        return NetworkService.instance
            .requestObject(PantauAuthAPI
                .votePreference(vote: vote, party: party),
                           c: BaseResponse<UserResponse>.self)
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .do(onNext: { (r) in
                AppState.saveMe(r.data)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
}
