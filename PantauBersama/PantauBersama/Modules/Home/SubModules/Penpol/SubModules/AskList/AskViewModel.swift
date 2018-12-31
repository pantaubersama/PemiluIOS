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
        let loadQuestionTrigger: AnyObserver<Void>
        let nextPageTrigger: AnyObserver<Void>
        let createTrigger: AnyObserver<Void>
        let infoTrigger: AnyObserver<Void>
        let shareTrigger: AnyObserver<QuestionModel>
        let moreTrigger: AnyObserver<QuestionModel>
        let moreMenuTrigger: AnyObserver<AskType>
    }
    
    struct Output {
        let askCells: BehaviorRelay<[ICellConfigurator]>
        let createSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let moreSelected: Driver<QuestionModel>
        let moreMenuSelected: Driver<Void>
        let userData: Driver<UserResponse?>
    }
    
    private let loadQuestionSubject = PublishSubject<Void>()
    private let nextPageSubject = PublishSubject<Void>()
    private let createSubject = PublishSubject<Void>()
    private let infoSubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<QuestionModel>()
    private let moreSubject = PublishSubject<QuestionModel>()
    private let moreMenuSubject = PublishSubject<AskType>()
    private let askCellRelay = BehaviorRelay<[ICellConfigurator]>(value: [])
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    private let navigator: QuizNavigator
    
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
        
        loadQuestionSubject
            .flatMapLatest({ self.askItem(resetPage: true) })
            .map { [weak self](list) -> [ICellConfigurator] in
                guard let weakSelf = self else { return [] }
                return list.map({ (questionModel) -> ICellConfigurator in
                    return AskViewCellConfigurator(item: AskViewCell.Input(viewModel: weakSelf, question: questionModel))
                })
            }.filter { (questions) -> Bool in
                return !questions.isEmpty
            }.bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.askCellRelay.accept(loadedItem)
            }.disposed(by: disposeBag)
        
        nextPageSubject
            .flatMapLatest({self.askItem()})
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
                var newItem = weakSelf.askCellRelay.value
                newItem.append(contentsOf: loadedItem)
                weakSelf.askCellRelay.accept(newItem)
            })
            .disposed(by: disposeBag)
        
        // MARK
        // Get user data from userDefaults
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData!)
        let user = Observable.just(userResponse).asDriverOnErrorJustComplete()
        
        output = Output(
            askCells: askCellRelay,
            createSelected: create,
            infoSelected: info,
            shareSelected: shareAsk,
            moreSelected: moreAsk,
            moreMenuSelected: moreMenuSelected,
            userData: user)
    }
    
    private func askItem(resetPage: Bool = false) -> Observable<[QuestionModel]> {
        if resetPage {
            currentPage = 0
        }
        currentPage += 1
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.getQuestions(page: currentPage, perpage: 10, filteredBy: .userVerifiedAll), c: QuestionsResponse.self)
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
