//
//  QuizResultViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class QuizResultViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let openSummaryTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
        let result: Driver<QuizResultModel>
        let openSummary: Driver<Void>
    }
    
    private let backSubject = PublishSubject<Void>()
    private let openSummarySubject = PublishSubject<Void>()
    
    var navigator: QuizResultNavigator
    var quiz: QuizModel
    
    init(navigator: QuizResultNavigator, quiz: QuizModel) {
        self.navigator = navigator
        self.quiz = quiz
        
        input = Input(backTrigger: backSubject.asObserver(),
                      openSummaryTrigger: openSummarySubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.finishQuiz() })
            .asDriverOnErrorJustComplete()
        
        let result = quizResult(id: quiz.id)
            .asDriverOnErrorJustComplete()
        
        let openSummary = openSummarySubject
            .map({ self.quiz })
            .flatMapLatest({ navigator.openSummary(quizModel: $0) })
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back,
                        result: result,
                        openSummary: openSummary)
    }
    
    private func quizResult(id: String) -> Observable<QuizResultModel> {
        return NetworkService.instance.requestObject(QuizAPI.getQuizResult(id: id), c: QuizResultResponse.self)
            .map({ (response) -> QuizResultModel in
                return QuizResultModel(result: response.data)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
