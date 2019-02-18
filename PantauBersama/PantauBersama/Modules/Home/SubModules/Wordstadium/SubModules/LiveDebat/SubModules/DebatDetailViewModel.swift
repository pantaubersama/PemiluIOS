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
        
    }
    
    struct Output {
        
    }
    
    private let navigator: DebatDetailNavigator
    init(navigator: DebatDetailNavigator) {
        self.navigator = navigator
    }
}
