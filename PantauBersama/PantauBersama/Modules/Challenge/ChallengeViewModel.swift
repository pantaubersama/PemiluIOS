//
//  ChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

enum ChallengeType {
    case soon
    case done
    case challenge
    case `default`
    case challengeOpen
    case challengeDirect
    case challengeDenied
    case challengeExpired
}

class ChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
    }
    
    private var navigator: ChallengeNavigator
    private var type: ChallengeType = .default
    
    private let backS = PublishSubject<Void>()
    
    init(navigator: ChallengeNavigator, type: ChallengeType) {
        self.navigator = navigator
        self.type = type
        
        input = Input(backI: backS.asObserver())
        
        
        
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        output = Output(backO: back)
    }
    
}
