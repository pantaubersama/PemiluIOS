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
    private let notePreferenceS = PublishSubject<String>()
    private let notePreferenceValueS = BehaviorSubject<Int>(value: 0)
    private let updateS = PublishSubject<Void>()
    
    init(navigator: CatatanNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(
            backI: backS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            updateI: updateS.asObserver()
        )
        
        let enable = notePreferenceValueS
            .map { (i) -> Bool in
                return i > 0
            }.startWith(false)
            .asDriverOnErrorJustComplete()
        
        let update = updateS
            .withLatestFrom(notePreferenceValueS)
            .flatMapLatest { [weak self] (i) -> Observable<BaseResponse<UserResponse>> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.votePreference(vote: i),
                                   c: BaseResponse<UserResponse>.self)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .do(onNext: { (r) in
                        AppState.saveMe(r.data)
                    })
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .mapToVoid()
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(enableO: enable,
                        updateO: update,
                        errorTracker: errorTracker.asDriver())
    }
}
