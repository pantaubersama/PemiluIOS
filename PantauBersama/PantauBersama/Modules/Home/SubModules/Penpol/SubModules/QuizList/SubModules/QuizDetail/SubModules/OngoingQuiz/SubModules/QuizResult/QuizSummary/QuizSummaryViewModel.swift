//
//  QuizAnswerViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class QuizSummaryViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let answerKeys: Driver<[QuizSummaryModel]>
        let quiz: Driver<QuizModel>
        let back: Driver<Void>
    }
    
    private let quiz: QuizModel
    private let backSubject = PublishSubject<Void>()
    
    init(quiz: QuizModel) {
        self.quiz = quiz
        
        input = Input(backTrigger: backSubject.asObserver())
        
        let answerKeys = self.quizSummary(id: quiz.id)
            .asDriverOnErrorJustComplete()
        
        let quizModel = Observable.just(quiz)
            .asDriverOnErrorJustComplete()
        
        let back = backSubject.asDriverOnErrorJustComplete()
        output = Output(answerKeys: answerKeys, quiz: quizModel, back: back)
    }
    
    private func quizSummary(id: String) -> Observable<[QuizSummaryModel]> {
        return NetworkService.instance.requestObject(QuizAPI.getQuizSummary(id: id), c: QuizSummaryResponse.self)
            .map({ (response) -> [QuizSummaryModel] in
                return response.data.questions.map({ (questionResponse) -> QuizSummaryModel in
                    return QuizSummaryModel(questionSummary: questionResponse)
                })
            })
            .asObservable()
            .catchErrorJustReturn([])
    }
}
