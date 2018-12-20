//
//  OnboardingViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

class OnboardingViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let siginTrigger: AnyObserver<Void>
        let bypassTrigger: AnyObserver<Void>
    }

    struct Output {
        let siginSelected: Driver<Void>
        let bypassSelected: Driver<Void>
    }

    private let navigator: OnboardingNavigator
    
    private let siginSubject = PublishSubject<Void>()
    private let bypassSubject = PublishSubject<Void>()
    
    init(navigator: OnboardingNavigator) {
        self.navigator = navigator
        
        input = Input(siginTrigger: siginSubject.asObserver(),
                      bypassTrigger: bypassSubject.asObserver())
        
        
        let sigin = siginSubject
            .flatMapLatest({ navigator.signIn() })
            .asDriver(onErrorJustReturn: ())
        
        let bypass = bypassSubject
            .flatMapLatest({ navigator.bypass() })
            .asDriver(onErrorJustReturn: ())
        
        
        output = Output(siginSelected: sigin,
                        bypassSelected: bypass)
    }
    
}
