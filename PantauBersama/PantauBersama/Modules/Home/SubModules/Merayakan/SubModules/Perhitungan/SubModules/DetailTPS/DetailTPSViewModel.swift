//
//  DetailTPSViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class DetailTPSViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let sendDataActionI: AnyObserver<Void>
        let successSubmitI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let sendDataActionO: Driver<Void>
        let successSubmitO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let navigator: DetailTPSNavigator
    
    private let successSubmitS = PublishSubject<Void>()
    private let sendDataActionS = PublishSubject<Void>()
    private let backS = PublishSubject<Void>()
    
    init(navigator: DetailTPSNavigator) {
        self.navigator = navigator
        
        input = Input(
            backI: backS.asObserver(),
            sendDataActionI: sendDataActionS.asObserver(),
            successSubmitI: successSubmitS.asObserver()
        )
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let sendDataAction = sendDataActionS
            .flatMap({ navigator.sendData() })
            .asDriverOnErrorJustComplete()
        
        let successSubmit = successSubmitS
            .flatMap({ navigator.successSubmit() })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            backO: back,
            sendDataActionO: sendDataAction,
            successSubmitO: successSubmit)
    }
}
