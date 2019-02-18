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
    private let backS = PublishSubject<Void>()
    
    init(navigator: ChallengeNavigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver())
        
        
        
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        output = Output(backO: back)
    }
    
}
