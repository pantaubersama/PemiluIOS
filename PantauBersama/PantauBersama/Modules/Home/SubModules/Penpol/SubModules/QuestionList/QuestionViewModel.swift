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

class QuestionViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let loadQuestionTrigger: AnyObserver<Void>
        let nextPageTrigger: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
        let infoTrigger: AnyObserver<Void>
        let shareTrigger: AnyObserver<QuestionModel>
        let moreTrigger: AnyObserver<QuestionModel>
        let moreMenuTrigger: AnyObserver<QuestionType>
    }
    
    struct Output {
        let questionCells: BehaviorRelay<[ICellConfigurator]>
        let createSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let moreSelected: Driver<QuestionModel>
        let moreMenuSelected: Driver<String>
        let userData: Driver<UserResponse?>
    }
    
    private let loadQuestionSubject = PublishSubject<Void>()
    private let nextPageSubject = PublishSubject<Void>()
    private let createSubject = PublishSubject<Void>()
    private let infoSubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<QuestionModel>()
    private let moreSubject = PublishSubject<QuestionModel>()
    private let moreMenuSubject = PublishSubject<QuestionType>()
    private let questionCellRelay = BehaviorRelay<[ICellConfigurator]>(value: [])
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    private let navigator: QuestionNavigator
    
    private(set) var disposeBag = DisposeBag()
    private var currentPage = 0
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(
            loadQuestionTrigger: loadQuestionSubject.asObserver(),
            nextPageTrigger: nextPageSubject.asObserver(),
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
        
        let moreQuestion = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let shareQuestion = shareSubject
            .flatMapLatest({navigator.shareQuestion(question: $0.body)})
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest({ [weak self](type) -> Observable<String> in
                guard let weakSelf = self else { return Observable.empty() }
                switch type {
                case .bagikan(let question):
                    let contentToShare = question.body
                    return navigator.shareQuestion(question: contentToShare)
                        .map({ (_) -> String in
                            return ""
                        })
                case .hapus(let question):
                    return Observable.empty()
                case .laporkan(let question):
                    return weakSelf.reportQuestion(question: question)
                case .salin(let question):
                    question.body.copyToClipboard()
                    return Observable.just("copied")
                }
            })
            .asDriverOnErrorJustComplete()
        
        loadQuestionSubject
            .flatMapLatest({ self.questionitem(resetPage: true) })
            .map { [weak self](list) -> [ICellConfigurator] in
                guard let weakSelf = self else { return [] }
                return list.map({ (questionModel) -> ICellConfigurator in
                    return AskViewCellConfigurator(item: AskViewCell.Input(viewModel: weakSelf, question: questionModel))
                })
            }.filter { (questions) -> Bool in
                return !questions.isEmpty
            }.bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.questionCellRelay.accept(loadedItem)
            }.disposed(by: disposeBag)
        
        nextPageSubject
            .flatMapLatest({ self.questionitem() })
            .map { [weak self](list) -> [ICellConfigurator] in
                guard let weakSelf = self else { return [] }
                return list.map({ (questionModel) -> ICellConfigurator in
                    return AskViewCellConfigurator(item: AskViewCell.Input(viewModel: weakSelf, question: questionModel))
                })
            }
            .filter({ (questions) -> Bool in
                return !questions.isEmpty
            })
            .bind(onNext: { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                var newItem = weakSelf.questionCellRelay.value
                newItem.append(contentsOf: loadedItem)
                weakSelf.questionCellRelay.accept(newItem)
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Get user data from userDefaults
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData!)
        let user = Observable.just(userResponse).asDriverOnErrorJustComplete()
        
        output = Output(
            questionCells: questionCellRelay,
            createSelected: create,
            infoSelected: info,
            shareSelected: shareQuestion,
            moreSelected: moreQuestion,
            moreMenuSelected: moreMenuSelected,
            userData: user)
    }
    
    private func questionitem(resetPage: Bool = false) -> Observable<[QuestionModel]> {
        if resetPage {
            currentPage = 0
        }
        currentPage += 1
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.getQuestions(page: currentPage, perpage: 10, filteredBy: .userVerifiedAll, orderedBy: .cachedVoteUp), c: QuestionsResponse.self)
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
    
    private func reportQuestion(question: QuestionModel) -> Observable<String> {
        // TODO: make sure what is className
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.reportQuestion(id: question.id, className: "Question"), c: QuestionReportResponse.self)
            .map { (response) -> String in
                return response.data.vote.status ? "success report" : response.data.vote.text
            }
            .asObservable()
            .catchErrorJustReturn("Oops something went wrong")
    }
}
