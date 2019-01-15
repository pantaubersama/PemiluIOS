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
        let searchInputTrigger: AnyObserver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let searchTrigger: PublishSubject<String>
    }
    
    var input: Input
    var output: Output!
    
    let navigator: SearchNavigator
    
    let backSubject = PublishSubject<Void>()
    let searchSubject = PublishSubject<String>()
    
    init(navigator: SearchNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver(), searchInputTrigger: searchSubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.finishSearch() })
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back, searchTrigger: searchSubject)
    }
}
