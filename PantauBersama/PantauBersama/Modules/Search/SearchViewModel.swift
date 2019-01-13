//
//  SearchViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class SearchViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output!
    
    let navigator: SearchNavigator
    
    init(navigator: SearchNavigator) {
        self.navigator = navigator
        
        input = Input()
        
        output = Output()
    }
}
