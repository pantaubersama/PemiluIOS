//
//  AskCellViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class AskCellViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init() {
        input = Input()
        output = Output()
    }
}
