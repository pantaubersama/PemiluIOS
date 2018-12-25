//
//  BadgeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import Common
import RxCocoa

class BadgeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
    }
    
    private let navigator: BadgeNavigator!
    private let backS = PublishSubject<Void>()
    
    init(navigator: BadgeNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver())
        output = Output()
    }
    
}
