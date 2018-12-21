//
//  QuizViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class QuizViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let openQuizTrigger: AnyObserver<Any>
        let shareTrigger: AnyObserver<Any>
    }
    
    struct Output {
        let openQuizSelected: Driver<Void>
        let shareSelected: Driver<Void>
    }
    
    // TODO: replace any with Quiz model
    private let openQuizSubject = PublishSubject<Any>()
    private let shareSubject = PublishSubject<Any>()
    
    private let navigator: QuizNavigator
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(
            openQuizTrigger: openQuizSubject.asObserver(),
            shareTrigger: shareSubject.asObserver())
        
        let openQuiz = openQuizSubject
            .flatMapLatest({navigator.openQuiz(quiz: $0)})
            .asDriver(onErrorJustReturn: ())
        let shareQuiz = shareSubject
            .flatMapLatest({navigator.shareQuiz(quiz: $0)})
            .asDriver(onErrorJustReturn: ())
        
        output = Output(
            openQuizSelected: openQuiz,
            shareSelected: shareQuiz)
    }
    
    
}
