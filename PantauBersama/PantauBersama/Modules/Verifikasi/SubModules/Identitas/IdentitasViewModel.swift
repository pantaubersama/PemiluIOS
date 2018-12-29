//
//  IdentitasViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

protocol IIdentitasViewModelInput {
    var backI: AnyObserver<Void> { get }
    var newKTPInput: AnyObserver<String> { get }
    var nextTrigger: AnyObserver<Void> { get }
}

protocol IIdentitasViewModelOutput {
    var enable: Driver<Bool>! { get }
    var errorTrackerO: Driver<Error>! { get }
    var changeO: Driver<Void>! { get }
}

protocol IIdentitasViewModel {
    var input: IIdentitasViewModelInput { get }
    var output: IIdentitasViewModelOutput { get }
}

final class IdentitasViewModel: IIdentitasViewModelInput, IIdentitasViewModelOutput, IIdentitasViewModel {
    
    var input: IIdentitasViewModelInput { return self }
    var output: IIdentitasViewModelOutput { return self }
    
    var navigator: IdentitasNavigator!
    
    // MARK: Input
    var backI: AnyObserver<Void>
    var newKTPInput: AnyObserver<String>
    var nextTrigger: AnyObserver<Void>
    // MARK: Output
    var enable: Driver<Bool>!
    var errorTrackerO: Driver<Error>!
    var changeO: Driver<Void>!
    
    // MARK: Subject
    private let backS = PublishSubject<Void>()
    private let verificationKtpSubject = PublishSubject<String>()
    private let nextSubject = PublishSubject<Void>()
    
    init(navigator: IdentitasNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        newKTPInput = verificationKtpSubject.asObserver()
        nextTrigger = nextSubject.asObserver()
        
        // MARK
        // Validation KTP
        // sak retiku KTP kudu 16
        let validateKtp = verificationKtpSubject
            .map({ $0.count == 16 })
            .startWith(false)
        
        // MARK
        // Trigger to next step if success
        // need string validation for KTP
        let changeAction = nextSubject
            .withLatestFrom(verificationKtpSubject)
            .flatMapLatest { (ktp) -> Driver<BaseResponse<VerificationsResponse>> in
                return NetworkService.instance
                .requestObject(PantauAuthAPI.putKTP(ktp: ktp),
                    c: BaseResponse<VerificationsResponse>.self)
                    .do(onSuccess: { (response) in
                        print(response.data.user)
                    })
                .trackError(errorTracker)
                .trackActivity(activityIndicator)
                .asDriverOnErrorJustComplete()
            }
            .flatMapLatest({ _ in navigator.launchSelfIdentitas() })
            .mapToVoid()
        
        let enableChange = Observable
            .combineLatest(validateKtp, activityIndicator.asObservable())
            .map { (v, a) -> Bool in
                return v && !a
        }
        
        
        // MARK
        // Output trigger if KTP Number acceptable or not
        enable = enableChange.asDriverOnErrorJustComplete()
        errorTrackerO = errorTracker.asDriver()
        changeO = changeAction.asDriverOnErrorJustComplete()
    }
}
