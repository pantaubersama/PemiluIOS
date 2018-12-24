//
//  ReqClusterViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

class ReqClusterViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let backI: AnyObserver<Void>
        
    }
    
    struct Output {
        let backO: Driver<Void>!
    }
    
    private let navigator: ReqClusterNavigator!
    private let backS = PublishSubject<Void>()
    
    init(navigator: ReqClusterNavigator) {
        self.navigator = navigator
        
        input = Input(
            backI: backS.asObserver()
        )
        
        let back = backS.do(onNext: { (_) in
            navigator.back()
        })
        
        output = Output(backO: back.asDriverOnErrorJustComplete())
    }
}
