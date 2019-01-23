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
    }
    
    private var navigator: CatatanNavigator
    private let backS = PublishSubject<Void>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private let viewWillAppearS = PublishSubject<Void>()
    private let notePreferenceValueS = BehaviorSubject<Int>(value: 0)
    private let partyPreferenceValueI = BehaviorSubject<String>(value: "")
    private let updateS = PublishSubject<Void>()
    
    init(navigator: CatatanNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(
            backI: backS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            notePreferenceValueI: notePreferenceValueS.asObserver(),
            partyPreferenceValueI: partyPreferenceValueI.asObserver(),
            updateI: updateS.asObserver()
        )
        
        let enable = Observable.combineLatest(notePreferenceValueS, partyPreferenceValueI.startWith(""))
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
                notePreferenceValueS.asObservable(), partyPreferenceValueI.startWith("")
                ))
            .flatMapLatest { [weak self] (i,s) -> Observable<BaseResponse<UserResponse>> in
                guard let `self` = self else { return Observable.empty() }
                return self.update(vote: i, party: s)
            }
            .mapToVoid()
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(enableO: enable,
                        updateO: update,
                        errorTracker: errorTracker.asDriver())
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
