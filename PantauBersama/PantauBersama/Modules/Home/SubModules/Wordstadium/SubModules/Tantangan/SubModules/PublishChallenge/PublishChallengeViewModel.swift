//
//  PublishChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

class PublishChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        
    }
    
    private let backS = PublishSubject<Void>()
    private var navigator: PublishChallengeNavigator
    private var type: Bool
    
    init(navigator: PublishChallengeNavigator, type: Bool) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.type = type
        
        input = Input(backI: backS.asObserver())
        
        
        output = Output()
        
    }
    
}
