//
//  DebatDetailViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 18/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Common
import Networking

class DebatDetailViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
        let challengeO: Driver<Challenge>
    }
    
    var input: Input
    var output: Output
    
    private let challenge: Challenge
    private let navigator: DebatDetailNavigator
    private let backS = PublishSubject<Void>()
    init(navigator: DebatDetailNavigator, challenge: Challenge) {
        self.navigator = navigator
        self.challenge = challenge
        
        input = Input(backTrigger: backS.asObserver())
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        let challengeView = Driver.just(self.challenge)
        output = Output(back: back, challengeO: challengeView)
    }
}
