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
    }
    
    private var navigator: ChallengeNavigator
    private var type: ChallengeType = .default
    
    private let backS = PublishSubject<Void>()
    private let actionButtonS = PublishSubject<Void>()
    
    init(navigator: ChallengeNavigator, type: ChallengeType) {
        self.navigator = navigator
        self.type = type
        
        input = Input(
            backI: backS.asObserver(),
            actionButtonI: actionButtonS.asObserver())
        
        
        
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let action = actionButtonS
            .flatMapLatest { [unowned self](_) -> Observable<Void> in
                switch self.type {
                case .challenge:
                    print("open challange")
                case .challengeDenied:
                    print("open challange denied")
                case .challengeDirect:
                    print("open challange direct")
                case .challengeExpired:
                    print("open challange expired")
                case .challengeOpen:
                    print("open challange open")
                case .done:
                    return self.navigator.openLiveDebatDone()
                case .soon:
                    print("open challange soon")
                case .default:
                    break
                }
                
                return Observable.empty()
        }
        .asDriverOnErrorJustComplete()
        
        output = Output(backO: back, actionO: action)
    }
    
}
