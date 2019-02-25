//
//  CreatePerhitunganViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class CreatePerhitunganViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    
    private let navigator: CreatePerhitunganNavigator
    
    init(navigator: CreatePerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input()
        
        output = Output()
    }
}
