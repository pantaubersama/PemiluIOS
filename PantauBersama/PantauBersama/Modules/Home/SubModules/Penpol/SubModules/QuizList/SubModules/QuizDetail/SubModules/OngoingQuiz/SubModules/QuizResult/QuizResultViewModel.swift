//
//  QuizResultViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class QuizResultViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    var navigator: QuizResultNavigator
    
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
    }
    
    private let backSubject = PublishSubject<Void>()
    
    init(navigator: QuizResultNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver())
        
        let back = backSubject.asDriverOnErrorJustComplete()
        
        output = Output(back: back)
    }
    
}
