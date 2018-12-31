//
//  CreateAskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class CreateAskViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
        let questionInput: BehaviorRelay<String>
    }
    
    struct Output {
        let createSelected: Driver<Void>
    }
    
    private let createSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let questionRelay = BehaviorRelay<String>(value: "")
    
    var navigator: CreateAskNavigator
    
    init(navigator: CreateAskNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver(),
                      createTrigger: createSubject.asObserver(),
                      questionInput: questionRelay)

        let create = createSubject
            .do {
                print("onNext")
            }
            .flatMap({ self.createQuestion() })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        self.navigator.finish = Observable
            .merge(backSubject, create.asObservable())
            .take(1)

        output = Output(createSelected: create)
    }
    
    private func createQuestion() -> Observable<QuestionModel> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.createQuestion(body: questionRelay.value), c: QuestionResponse.self)
            .map({ (questionResponse) -> QuestionModel in
                return QuestionModel(question: questionResponse.data.question)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
