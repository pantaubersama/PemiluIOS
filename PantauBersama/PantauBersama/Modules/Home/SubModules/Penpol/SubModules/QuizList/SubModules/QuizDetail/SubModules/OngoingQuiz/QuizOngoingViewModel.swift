//
//  QuizOngoingViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class QuizOngoingViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let answerATrigger: AnyObserver<Void>
        let answerBTrigger: AnyObserver<Void>
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let answerA: Driver<Void>
        let answerB: Driver<Void>
        let back: Driver<Void>
        let question: Driver<[String]>
    }
    
    let answerASubject = PublishSubject<Void>()
    let answerBSubject = PublishSubject<Void>()
    let backSubject = PublishSubject<Void>()
    
    let navigator: QuizOngoingNavigator
    
    private(set) var disposeBag = DisposeBag()
    
    init(navigator: QuizOngoingNavigator) {
        self.navigator = navigator
        // TODO: remove dummy data
        let questions = [["a", "b"], ["c", "d"]]
        let questionIndex = BehaviorSubject<Int>.init(value: 0)
        
        func answerQuestion() -> Observable<Bool> {
            do {
                let index = try questionIndex.value()
                if index < questions.count - 1 {
                    questionIndex.onNext(index + 1)
                    
                    return Observable.just(false)
                }
                
                return Observable.just(true)
            } catch let error {
                print("error answer \(error.localizedDescription)")
                return Observable.just(false)
                
            }
        }
        
        input = Input(answerATrigger: answerASubject.asObserver(),
                      answerBTrigger: answerASubject.asObserver(),
                      backTrigger: backSubject.asObserver())
        
        let answerA = answerASubject.flatMap({answerQuestion()})
            .flatMap({navigator.openQuizResult(finishQuiz: $0)})
            .asDriverOnErrorJustComplete()
        
        let answerB = answerBSubject.flatMap({answerQuestion()})
            .flatMap({navigator.openQuizResult(finishQuiz: $0)})
            .asDriverOnErrorJustComplete()
        
        let back = backSubject
            .map { (_) -> Void in
                do {
                    let index = try questionIndex.value()
                    if index == 0 {
                        navigator.exitQuiz()
                    } else {
                        questionIndex.onNext(index - 1)
                    }
                } catch let error {
                    print("error answer \(error.localizedDescription)")
                }
            }.asDriverOnErrorJustComplete()
        
        let questionDriver = questionIndex.asObservable()
            .map({questions[$0]})
            .asDriverOnErrorJustComplete()
        
        
        output = Output(answerA: answerA, answerB: answerB, back: back, question: questionDriver)
    }
}
