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
        let actionButtonI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let actionO: Driver<Void>
        let challengeO: Driver<Challenge>
    }
    
    private var navigator: ChallengeNavigator
    private var data: Challenge
    
    private let backS = PublishSubject<Void>()
    private let actionButtonS = PublishSubject<Void>()
    
    init(navigator: ChallengeNavigator, data: Challenge) {
        self.navigator = navigator
        self.data = data
        
        input = Input(
            backI: backS.asObserver(),
            actionButtonI: actionButtonS.asObserver())
        
        
        
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let action = actionButtonS
            .flatMapLatest { [unowned self](_) -> Observable<PopupChallengeResult> in
                if self.data.progress == .waitingOpponent {
                    return navigator.openAcceptConfirmation()
                }
                
                return Observable.empty()
            }
            .do(onNext: { (result) in
                print("result \(result)")
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back, actionO: action, challengeO: Driver.just(data))
    }
    
}
