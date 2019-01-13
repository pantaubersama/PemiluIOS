//
//  SearchViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class SearchViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    
    let navigator: SearchNavigator
    
    let backSubject = PublishSubject<Void>()
    
    init(navigator: SearchNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.finishSearch() })
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back)
    }
}
