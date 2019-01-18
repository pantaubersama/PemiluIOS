//
//  UpdatesViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

final class UpdatesViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    
    struct Input {
        let updateI: AnyObserver<Void>
        let nextTimeI: AnyObserver<Void>
    }
    
    struct Output {
        let updateO: Driver<Void>
        let nextTimeO: Driver<Void>
        let typeO: Driver<TypeUpdates>
    }
    
    private var navigator: UpdatesNavigator!
    private let updateS = PublishSubject<Void>()
    private let nextTimeS = PublishSubject<Void>()
    private var type: TypeUpdates!
    
    init(navigator: UpdatesNavigator, type: TypeUpdates) {
        self.navigator = navigator
        self.type = type
        
        input = Input(
            updateI: updateS.asObserver(),
            nextTimeI: nextTimeS.asObserver()
        )
        
        output = Output(
            updateO: updateS.asDriverOnErrorJustComplete(),
            nextTimeO: nextTimeS.asDriverOnErrorJustComplete(),
            typeO: Observable.just(type).asDriverOnErrorJustComplete()
        )
    }
    
    
}
