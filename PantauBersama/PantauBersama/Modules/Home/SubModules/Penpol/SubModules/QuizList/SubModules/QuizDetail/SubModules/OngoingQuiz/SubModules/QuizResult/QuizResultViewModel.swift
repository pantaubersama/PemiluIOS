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
    }
    
    struct Output {
        let back: Driver<Void>
        let result: Driver<QuizResultModel>
    }
    
    private let backSubject = PublishSubject<Void>()
    
    var navigator: QuizResultNavigator
    var quiz: QuizModel
    
    init(navigator: QuizResultNavigator, quiz: QuizModel) {
        self.navigator = navigator
        self.quiz = quiz
        
        input = Input(backTrigger: backSubject.asObserver())
        
        let back = backSubject.asDriverOnErrorJustComplete()
        
        let result = quizResult(id: quiz.id)
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back, result: result)
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
