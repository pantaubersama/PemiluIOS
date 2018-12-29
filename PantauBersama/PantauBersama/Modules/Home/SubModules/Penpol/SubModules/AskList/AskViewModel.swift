//
//  AskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking
import RxDataSources

class AskViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let nextPage: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
        let infoTrigger: AnyObserver<Void>
        let shareTrigger: AnyObserver<Any>
        let moreTrigger: AnyObserver<Any>
        let moreMenuTrigger: AnyObserver<AskType>
    }
    
    struct Output {
        let askCells: Driver<[ICellConfigurator]>
        let createSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let moreSelected: Driver<Any>
        let moreMenuSelected: Driver<Void>
        
    }
    
    // TODO: replace any with Ask model
    private let nextPageSubject = PublishSubject<Void>()
    private let createSubject = PublishSubject<Void>()
    private let infoSubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<Any>()
    private let moreSubject = PublishSubject<Any>()
    private let moreMenuSubject = PublishSubject<AskType>()
    
    private let navigator: QuizNavigator
    private let questionSectionModel: [SectionModel<String, Any>] = []
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(
            nextPage: nextPageSubject.asObserver(),
            createTrigger: createSubject.asObserver(),
            infoTrigger: infoSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver())
        
        let create = createSubject
            .flatMapLatest({navigator.launchCreateAsk()})
            .asDriver(onErrorJustReturn: ())
        let info = infoSubject
            .flatMapLatest({navigator.openInfoPenpol(infoType: PenpolInfoType.Ask)})
            .asDriver(onErrorJustReturn: ())
        
        let moreAsk = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let shareAsk = shareSubject
            .flatMapLatest({navigator.shareAsk(ask: $0)})
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest({ (type) -> Observable<Void> in
                switch type {
                case .bagikan(let ask):
                    return navigator.shareAsk(ask: ask)
                default :
                    return Observable.empty()
                }
            })
            .asDriverOnErrorJustComplete()
        
        let askCells = askItem().map { (list) -> [ICellConfigurator] in
            return list.map({ (questionModel) -> ICellConfigurator in
                return AskViewCellConfigurator(item: AskViewCell.Input(viewModel: self, question: questionModel))
            })
        }.asDriverOnErrorJustComplete()
        
        
        output = Output(
            askCells: askCells,
            createSelected: create,
            infoSelected: info,
            shareSelected: shareAsk,
            moreSelected: moreAsk,
            moreMenuSelected: moreMenuSelected)
    }
    
    private func askItem() -> Observable<[QuestionModel]> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.getQuestions(page: 1, perpage: 10, filteredBy: .userVerifiedAll), c: QuestionsResponse.self)
            .map { [weak self](response) -> [QuestionModel] in
                guard let weakSelf = self else { return [] }
                return weakSelf.generateQuestions(from: response)
            }
            .asObservable()
            .catchErrorJustReturn([])
    }
    
    private func generateQuestions(from questionResponse: QuestionsResponse) -> [QuestionModel] {
        return questionResponse.data.questions.map({ (questionResponse) -> QuestionModel in
            return QuestionModel(question: questionResponse)
        })
    }
}
