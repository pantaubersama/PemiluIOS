//
//  QuizDetailViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class QuizDetailViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let startTrigger: AnyObserver<Void>
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let startSelected: Driver<Void>
        let back: Driver<Void>
    }
    
    private let startSubject = PublishSubject<Void>()
    private let backS = PublishSubject<Void>()
    
    var navigator: QuizDetailNavigator
    
    init(navigator: QuizDetailNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(startTrigger: startSubject.asObserver(), backTrigger: backS.asObserver())
        
        let start = startSubject
            .flatMap({navigator.startQuiz()})
            .asDriver(onErrorJustReturn: ())
        
        let back = backS.asDriverOnErrorJustComplete()
        
        output = Output(startSelected: start, back: back)
    }
    
}
