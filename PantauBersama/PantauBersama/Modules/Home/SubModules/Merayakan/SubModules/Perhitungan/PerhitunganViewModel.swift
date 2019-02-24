//
//  PerhitunganViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class PerhitunganViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    private let navigator: PerhitunganNavigator
    
    init(navigator: PerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input()
        output = Output()
    }
}
