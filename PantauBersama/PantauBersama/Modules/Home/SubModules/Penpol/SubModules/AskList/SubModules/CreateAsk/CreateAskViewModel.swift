//
//  CreateAskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class CreateAskViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let createSelected: Driver<Void>
    }
    
    private let createSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    var navigator: CreateAskNavigator
    
    
    
    init(navigator: CreateAskNavigator) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(backTrigger: backSubject.asObserver() ,createTrigger: createSubject.asObserver())

        let create = createSubject
            .asDriver(onErrorJustReturn: ())

        output = Output(createSelected: create )
    }
    
}
