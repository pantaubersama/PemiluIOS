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
        let notePreferenceI: AnyObserver<String>
        let notePreferenceValueI: BehaviorSubject<Int>
    }
    
    struct Output {
        let totalResultO: Driver<TrendResponse>
        let userDataO: Driver<UserResponse>
        let notePreferenceO: Driver<String>
        let notePreferenceValueO: Driver<Int>
    }
    
    private var navigator: CatatanNavigator
    private let backS = PublishSubject<Void>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private let viewWillAppearS = PublishSubject<Void>()
    private let notePreferenceS = PublishSubject<String>()
    private let notePreferenceValueS = BehaviorSubject<Int>(value: 0)
    
    init(navigator: CatatanNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(
            backI: backS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            notePreferenceI: notePreferenceS.asObserver(),
            notePreferenceValueI: notePreferenceValueS.asObserver()
        )
        
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
        
        let totalResult = viewWillAppearS
            .flatMapLatest({ self.totalResult() })
            .asDriverOnErrorJustComplete()
        
        let note = notePreferenceS
            .asDriverOnErrorJustComplete()
        
        
        output = Output(totalResultO: totalResult,
                        userDataO: userData.asDriverOnErrorJustComplete(),
                        notePreferenceO: note,
                        notePreferenceValueO: notePreferenceValueS.asDriverOnErrorJustComplete())
    }
    
    private func totalResult() -> Observable<TrendResponse> {
        return NetworkService.instance
            .requestObject(QuizAPI.getTotalResult(),
                           c: BaseResponse<TrendResponse>.self)
            .map({ $0.data })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
