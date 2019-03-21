//
//  InputC1ViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class C1InputFormViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let navigator: C1InputFormNavigator
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    
    init(navigator: C1InputFormNavigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back)
    }
}
