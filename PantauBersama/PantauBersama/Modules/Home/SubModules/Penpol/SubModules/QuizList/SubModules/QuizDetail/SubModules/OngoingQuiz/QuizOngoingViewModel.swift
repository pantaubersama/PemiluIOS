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
import Networking

class QuizOngoingViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let loadQuestionTrigger: AnyObserver<Void>
        let answerATrigger: AnyObserver<Void>
        let answerBTrigger: AnyObserver<Void>
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let quiz: Driver<QuizModel>
        let answerA: Driver<Void>
        let answerB: Driver<Void>
        let back: Driver<Void>
        let question: Driver<QuizQuestionModel>
        let questionsIndexTitle: Driver<String>
    }
    
    let loadQuestionSubject = PublishSubject<Void>()
    let answerASubject = PublishSubject<Void>()
    let answerBSubject = PublishSubject<Void>()
    let backSubject = PublishSubject<Void>()
    let questionRelay = BehaviorRelay<[QuizQuestionModel]>(value: [])
    
    let navigator: QuizOngoingNavigator
    let quiz: QuizModel
    
    private(set) var disposeBag = DisposeBag()
    
    init(navigator: QuizOngoingNavigator, quiz: QuizModel) {
        self.navigator = navigator
        self.quiz = quiz
        
        input = Input(loadQuestionTrigger: loadQuestionSubject.asObserver(),
                      answerATrigger: answerASubject.asObserver(),
                      answerBTrigger: answerASubject.asObserver(),
                      backTrigger: backSubject.asObserver())
        
        let questionIndex = BehaviorSubject<Int>.init(value: 0)
        
        func answerQuestion() -> Observable<Bool> {
            do {
                let index = try questionIndex.value()
                if index < questionRelay.value.count - 1 {
                    questionIndex.onNext(index + 1)
                    
                    return Observable.just(false)
                }
                
                return Observable.just(true)
            } catch let error {
                print("error answer \(error.localizedDescription)")
                return Observable.just(false)
                
            }
        }
        
        let answerA = answerASubject.flatMap({ answerQuestion() })
            .flatMap({ navigator.openQuizResult(finishQuiz: $0) })
            .asDriverOnErrorJustComplete()
        
        let answerB = answerBSubject.flatMap({ answerQuestion() })
            .flatMap({ navigator.openQuizResult(finishQuiz: $0) })
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
            .skipWhile({ [weak self](_) -> Bool in
                return self?.questionRelay.value.isEmpty ?? true
            })
            .map({ self.questionRelay.value[$0] })
            .asDriverOnErrorJustComplete()
        
        let questionIndexTitle = questionIndex.asObserver()
            .map({ "Pertanyaan no \($0 + 1) dari \(self.quiz.questionCount)" })
            .asDriver(onErrorJustReturn: "")
        
        loadQuestionSubject
            .flatMapLatest({ self.quizQuestions(id: self.quiz.id) })
            .bind { [weak self](questions) in
                guard let weakSelf = self else { return }
                weakSelf.questionRelay.accept(questions)
                questionIndex.onNext(0)
            }
            .disposed(by: disposeBag)
        
        output = Output(quiz: Observable.just(quiz).asDriverOnErrorJustComplete(),
                        answerA: answerA,
                        answerB: answerB,
                        back: back,
                        question: questionDriver,
                        questionsIndexTitle: questionIndexTitle)
    }
    
    private func quizQuestions(id: String) -> Observable<[QuizQuestionModel]> {
        return NetworkService.instance.requestObject(QuizAPI.getQuizQuestions(id: id), c: QuizQuestionsResponse.self)
            .map({ (response) -> [QuizQuestionModel] in
                return response.data.questions.map({ (questionResponse) -> QuizQuestionModel in
                    return QuizQuestionModel(quizQuestion: questionResponse)
                })
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
    
}
