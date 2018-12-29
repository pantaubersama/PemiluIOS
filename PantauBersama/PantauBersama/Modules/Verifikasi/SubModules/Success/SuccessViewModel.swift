//
//  SuccessViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

class SuccessViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let finishI: AnyObserver<Void>
    }
    
    struct Output {
        let finishO: Driver<Void>
    }
    
    var navigator: SuccessNavigator
    private let finishS = PublishSubject<Void>()
    
    init(navigator: SuccessNavigator) {
        self.navigator = navigator
        
        input = Input(finishI: finishS.asObserver())
        
        let finish = finishS
            .do(onNext: { (_) in
                navigator.finish()
            })
        
        output = Output(finishO: finish.asDriverOnErrorJustComplete())
    }
}
