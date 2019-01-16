//
//  AboutViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 16/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa


final class AboutViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
    }
    
    private var navigator: AboutNavigator
    private let backS = PublishSubject<Void>()
    
    init(navigator: AboutNavigator) {
        self.navigator = navigator
        
        
        input = Input(backI: backS.asObserver())
        
        let back = backS
            .do(onNext: { (_) in
                navigator.back()
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back)
        
    }
    
}
