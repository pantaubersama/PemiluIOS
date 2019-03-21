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
        let createPerhitunganI: AnyObserver<Void>
    }
    
    struct Output {
        let createPerhitunganO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    private let navigator: PerhitunganNavigator
    
    private let createPerhitunganS = PublishSubject<Void>()
    
    init(navigator: PerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input(createPerhitunganI: createPerhitunganS.asObserver())
        
        let createPerhitungan = createPerhitunganS
            .flatMap({ navigator.launchCreatePerhitungan() })
            .asDriverOnErrorJustComplete()
        
        output = Output(createPerhitunganO: createPerhitungan)
    }
}
