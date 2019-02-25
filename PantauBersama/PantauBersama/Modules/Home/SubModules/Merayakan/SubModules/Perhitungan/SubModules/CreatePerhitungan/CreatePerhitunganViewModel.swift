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
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let navigator: CreatePerhitunganNavigator
    private let backS = PublishSubject<Void>()
    
    init(navigator: CreatePerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back)
    }
}
