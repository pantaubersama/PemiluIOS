//
//  AskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class AskViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let createTrigger: AnyObserver<Void>
        let infoTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let createSelected: Driver<Void>
        let infoSelected: Driver<Void>
    }
    
    // TODO: replace any with Quiz model
    private let createSubject = PublishSubject<Void>()
    private let infoSubject = PublishSubject<Void>()
    
    private let navigator: QuizNavigator
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(
            createTrigger: createSubject.asObserver(),
            infoTrigger: infoSubject.asObserver())
        
        let create = createSubject
            .flatMapLatest({navigator.launchCreateAsk()})
            .asDriver(onErrorJustReturn: ())
        let info = infoSubject
            .flatMapLatest({navigator.openInfoPenpol(infoType: PenpolInfoType.Ask)})
            .asDriver(onErrorJustReturn: ())
        
        output = Output(
            createSelected: create,
            infoSelected: info)
    }
    
    
}
