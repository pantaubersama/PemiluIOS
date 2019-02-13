//
//  LiveDebatViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class LiveDebatViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
    }
    
    var input: Input
    var output: Output
    var navigator: LiveDebatNavigator
    
    private let backS = PublishSubject<Void>()
    
    init(navigator: LiveDebatNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backS.asObserver())
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back)
    }
}
