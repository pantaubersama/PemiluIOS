//
//  SuccessPromoteViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

final class SuccessPromoteViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let dismissI: AnyObserver<Void>
    }
    
    struct Output {
        let dismissO: Driver<Void>
    }
    
    private let dismissS = PublishSubject<Void>()
    var navigator: SuccessPromoteNavigator!
    
    init(navigator: SuccessPromoteNavigator) {
        self.navigator = navigator
        
        input = Input(dismissI: dismissS.asObserver())
        
        let dismiss = dismissS
            .flatMapLatest({ _ in navigator.dismiss() })
            .asDriverOnErrorJustComplete()
        
        output = Output(dismissO: dismiss)
    }
    
}
