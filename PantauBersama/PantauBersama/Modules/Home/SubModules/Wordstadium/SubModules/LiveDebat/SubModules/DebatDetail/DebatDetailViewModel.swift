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
    }
    
    var input: Input
    var output: Output
    
    private let navigator: DebatDetailNavigator
    private let backS = PublishSubject<Void>()
    init(navigator: DebatDetailNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backS.asObserver())
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back)
    }
}
