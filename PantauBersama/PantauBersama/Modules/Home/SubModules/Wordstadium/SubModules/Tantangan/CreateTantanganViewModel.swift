//
//  CreateTantanganViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

class CreateTantanganViewModel: ViewModelType {
    
    var input: Input!
    var output: Output!
    
    struct Input {
        let openTrigger: AnyObserver<Void>
        let directTrigger: AnyObserver<Void>
        let backTriggger: AnyObserver<Void>
    }
    
    struct Output {
        let openSelected: Driver<Void>
        let directSelected: Driver<Void>
    }
    
    private var navigator: CreateTantanganNavigator
    private let openSubject = PublishSubject<Void>()
    private let directSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    
    init(navigator: CreateTantanganNavigator) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(openTrigger: openSubject.asObserver(),
                      directTrigger: directSubject.asObserver(), backTriggger: backSubject.asObserver())
        
        let open = openSubject
            .flatMapLatest({ navigator.launchOpen() })
            .asDriverOnErrorJustComplete()
        
        let direct = directSubject
            .flatMapLatest({ navigator.launchDirect() })
            .asDriverOnErrorJustComplete()
        
        
        output = Output(openSelected: open,
                        directSelected: direct)
    }
    
}
