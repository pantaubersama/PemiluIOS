//
//  HintTantanganViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa


final class HintTantanganViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let closeI: AnyObserver<Void>
    }
    
    struct Output {
        let hintO: Driver<HintType>
    }
    
    private var navigator: HintTantantanganNavigator
    private let closeS = PublishSubject<Void>()
    
    init(navigator: HintTantantanganNavigator, type: HintType) {
        self.navigator = navigator
        self.navigator.finish = closeS
        
        input = Input(closeI: closeS.asObserver())
        
        output = Output(hintO: Driver.just(type))
    }
    
}
