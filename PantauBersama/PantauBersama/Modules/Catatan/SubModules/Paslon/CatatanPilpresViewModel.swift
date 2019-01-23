//
//  CatatanPilpresViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

class CatatanPilpresViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    struct Input {
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
    
    private let viewWillAppearS = PublishSubject<Void>()
    private let notePreferenceS = PublishSubject<String>()
    private let notePreferenceValueS = BehaviorSubject<Int>(value: 0)
    
    init() {
        
        input = Input(
            viewWillAppearI: viewWillAppearS.asObserver(),
            notePreferenceI: notePreferenceS.asObserver(),
            notePreferenceValueI: notePreferenceValueS.asObserver()
        )
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
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
            .flatMapLatest({ (_) -> Observable<TrendResponse> in
                return NetworkService.instance
                    .requestObject(QuizAPI.getTotalResult(),
                                   c: BaseResponse<TrendResponse>.self)
                    .map({ $0.data })
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asObservable()
                    .catchErrorJustComplete()
            })
            .asDriverOnErrorJustComplete()
        
        let note = notePreferenceS
            .asDriverOnErrorJustComplete()
        
        output = Output(
            totalResultO: totalResult,
            userDataO: userData.asDriverOnErrorJustComplete(),
            notePreferenceO: note,
            notePreferenceValueO: notePreferenceValueS.asDriverOnErrorJustComplete()
        )
    }
    
}
