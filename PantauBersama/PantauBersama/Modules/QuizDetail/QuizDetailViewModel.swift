//
//  QuizDetailViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class QuizDetailViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var navigator: QuizDetailNavigator
    
    let backS = PublishSubject<Void>()
    
    init(navigator: QuizDetailNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input()
        
        output = Output()
    }
    
}
