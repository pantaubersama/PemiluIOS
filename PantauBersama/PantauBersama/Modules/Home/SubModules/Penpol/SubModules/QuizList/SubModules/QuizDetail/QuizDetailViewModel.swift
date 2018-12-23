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
    }
    
    struct Output {
        let startSelected: Driver<Void>
    }
    
    private let startSubject = PublishSubject<Void>()
    var navigator: QuizDetailNavigator
    
    let backS = PublishSubject<Void>()
    
    init(navigator: QuizDetailNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(startTrigger: startSubject.asObserver())
        
        let start = startSubject
            .flatMap({navigator.startQuiz()})
            .asDriver(onErrorJustReturn: ())
        
        output = Output(startSelected: start)
    }
    
}
