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
        let shareTrigger: AnyObserver<UIImage?>
    }
    
    struct Output {
        let back: Driver<Void>
        let result: Driver<QuizResultModel>
        let openSummary: Driver<Void>
        let share: Driver<Void>
    }
    
    private let backSubject = PublishSubject<Void>()
    private let openSummarySubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<UIImage?>()
    
    var navigator: QuizResultNavigator
    var quiz: QuizModel?
    private var isFromDeeplink: Bool
    private var participationURL: String?
    
    init(navigator: QuizResultNavigator, quiz: QuizModel?, isFromDeeplink: Bool, participationURL: String?) {
        self.navigator = navigator
        self.quiz = quiz
        self.isFromDeeplink = isFromDeeplink
        self.participationURL = participationURL
        
        input = Input(backTrigger: backSubject.asObserver(),
                      openSummaryTrigger: openSummarySubject.asObserver(),
                      shareTrigger: shareSubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.finishQuiz() })
            .asDriverOnErrorJustComplete()
        
        let result = quizResult(id: quiz?.id ?? "")
        
        let openSummary = openSummarySubject
            .map({ self.quiz })
            .flatMapLatest({ navigator.openSummary(quizModel: $0) })
            .asDriverOnErrorJustComplete()
        
        let share = Observable.combineLatest(shareSubject, result)
            .flatMapLatest({ (image, quiz) -> Observable<Void> in
                if let image = image {
                    return navigator.shareQuizResult(quizModel: quiz.shareURL, image: image)
                } else {
                    return Observable.empty()
                }
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back,
                        result: result.asDriverOnErrorJustComplete(),
                        openSummary: openSummary,
                        share: share)
    }
    
    private func quizResult(id: String) -> Observable<QuizResultModel> {
        if isFromDeeplink == false && participationURL == nil {
            return NetworkService.instance.requestObject(QuizAPI.getQuizResult(id: id), c: QuizResultResponse.self)
                .map({ (response) -> QuizResultModel in
                    print("Response Result: \(response)")
                    return QuizResultModel(result: response.data)
                })
                .asObservable()
                .catchErrorJustComplete()
        } else {
            return NetworkService.instance.requestObject(QuizAPI.getQuizParticipationResult(id: participationURL ?? ""),
                                                         c: QuizResultResponse.self)
                .map({ (response) -> QuizResultModel in
                    return QuizResultModel(result: response.data)
                })
                .asObservable()
                .catchErrorJustComplete()
        }
    }
    
}
