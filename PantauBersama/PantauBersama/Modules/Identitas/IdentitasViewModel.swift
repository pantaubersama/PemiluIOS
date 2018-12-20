//
//  IdentitasViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking


class IdentitasViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let backOutput: Driver<Void>!
    }
    
    var navigator: IdentitasNavigator!
    
    private let backSubject = PublishSubject<Void>()
    
    init(navigator: IdentitasNavigator) {
        self.navigator = navigator
    
        input = Input(backTrigger: backSubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.back() })
            .asDriver(onErrorJustReturn: ())
        
        output = Output(backOutput: back)
    }
}
