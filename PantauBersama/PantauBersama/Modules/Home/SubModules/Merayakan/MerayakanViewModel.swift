//
//  RekapViewModel.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class MerayakanViewModel: ViewModelType {
    
    var input: Input
    var output: Output

    struct Input {
        
    }
    
    struct Output {
        
    }
    
    let navigator: MerayakanNavigator
    
    init(navigator: MerayakanNavigator) {
        self.navigator = navigator
    
        input = Input(
        
        )
        
        output = Output(
            
        )
    }
}
