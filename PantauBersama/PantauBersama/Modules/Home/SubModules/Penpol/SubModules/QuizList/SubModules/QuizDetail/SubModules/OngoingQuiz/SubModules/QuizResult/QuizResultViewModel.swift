//
//  QuizResultViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common

class QuizResultViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    var navigator: QuizResultNavigator
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    
    init(navigator: QuizResultNavigator) {
        self.navigator = navigator
        
        input = Input()
        
        output = Output()
    }
    
}
