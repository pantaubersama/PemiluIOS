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
        let voteTrigger: AnyObserver<QuestionModel>
        let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
    }
    
    struct Output {
        let question: BehaviorRelay<[QuestionModel]>
        let createSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let moreSelected: Driver<QuestionModel>
        let moreMenuSelected: Driver<String>
        let userData: Driver<UserResponse?>
        let loadingIndicator: Driver<Bool>
        let deletedQuestoinIndex: Driver<Int>
        let bannerInfo: Driver<BannerInfo>
        let filter: Driver<Void>
        let showHeader: Driver<Bool>
    }
    
    private let loadQuestionSubject = PublishSubject<Void>()
    private let nextPageSubject = PublishSubject<Void>()
    private let createSubject = PublishSubject<Void>()
    private let infoSubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<QuestionModel>()
    private let moreSubject = PublishSubject<QuestionModel>()
    private let moreMenuSubject = PublishSubject<QuestionType>()
    private let questionRelay = BehaviorRelay<[QuestionModel]>(value: [])
    private let deletedQuestionSubject = PublishSubject<Int>()
    private let voteSubject = PublishSubject<QuestionModel>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    private let navigator: QuestionNavigator
    
    private(set) var disposeBag = DisposeBag()
    private var currentPage = 0
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    
    let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: PenpolNavigator, showTableHeader: Bool) {
        self.navigator = navigator
        input = Input(
            loadQuestionTrigger: loadQuestionSubject.asObserver(),
            nextPageTrigger: nextPageSubject.asObserver(),
            createTrigger: createSubject.asObserver(),
            infoTrigger: infoSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver(),
            voteTrigger: voteSubject.asObserver(),
            filterTrigger: filterSubject.asObserver())
        
        // TODO: ELEK GARIS KERAS
        let cachedFilter = PenpolFilterModel.generateQuestionFilter()
        cachedFilter.forEach { (filterModel) in
            let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                return filterItem.isSelected
            })
            self.filterItems.append(contentsOf: selectedItem)
        }
        
        let create = createSubject
            .flatMapLatest({navigator.launchCreateAsk()})
            .asDriver(onErrorJustReturn: ())
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        let moreQuestion = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let shareQuestion = shareSubject
            .flatMapLatest({navigator.shareQuestion(question: $0.body)})
            .asDriver(onErrorJustReturn: ())
        
        let bannerInfo = loadQuestionSubject
            .flatMapLatest({ self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
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
                    return weakSelf.deleteQuestion(question: question)
                        .do(onNext: { (result) in
                            var currentValue = weakSelf.questionRelay.value
                            guard let index = currentValue.index(where: { item -> Bool in
                                return item.id == result.question.id
                            }) else {
                                return
                            }
                            
                            currentValue.remove(at: index)
                            weakSelf.questionRelay.accept(currentValue)
                        })
                        .map({ (result) -> String in
                            return result.status ? "delete succeeded" : "delete failed"
                        })
                case .laporkan(let question):
                    return weakSelf.reportQuestion(question: question)
                case .salin(let question):
                    question.body.copyToClipboard()
                    return Observable.just("copied")
                }
            })
            .asDriverOnErrorJustComplete()
        
        let filter = filterSubject
            .do(onNext: { [weak self](filterItems) in
                guard let weakSelf = self else { return }
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("question")
                })
                
                if !filter.isEmpty {
                    weakSelf.filterItems = filterItems
                }
                
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        loadQuestionSubject
            .flatMapLatest({ [weak self](_) -> Observable<[QuestionModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.questionitem(resetPage: true)
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
            })
            .filter { (questions) -> Bool in
                return !questions.isEmpty
            }.bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.questionRelay.accept(loadedItem)
            }.disposed(by: disposeBag)
        
        nextPageSubject
            .flatMapLatest({ self.questionitem() })
            .filter({ (questions) -> Bool in
                return !questions.isEmpty
            })
            .bind(onNext: { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                var newItem = weakSelf.questionRelay.value
                newItem.append(contentsOf: loadedItem)
                weakSelf.questionRelay.accept(newItem)
            })
            .disposed(by: disposeBag)
        
        voteSubject
            .flatMapLatest({ self.voteQuestion(question: $0) })
            .filter({ $0.status })
            .bind { [weak self](result) in
                guard let weakSelf = self else { return }
                if !result.status { return }
                
                var currentValue = weakSelf.questionRelay.value
                guard let index = currentValue.index(where: { item -> Bool in
                    return item.id == result.questionId
                }) else {
                    return
                }
                
                var updateQuestion = currentValue[index]
                updateQuestion.isLiked = true
                updateQuestion.likeCount = updateQuestion.likeCount + 1
                currentValue.remove(at: index)
                currentValue.insert(updateQuestion, at: index)
                weakSelf.questionRelay.accept(currentValue)
            }
            .disposed(by: disposeBag)
        
        // MARK
        // Get user data from userDefaults
        let userData: Data? = UserDefaults.Account.get(forKey: .me)
        let userResponse = try? JSONDecoder().decode(UserResponse.self, from: userData ?? Data())
        let user = Observable.just(userResponse).asDriverOnErrorJustComplete()
        
        let showTableHeader = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        output = Output(
            question: questionRelay,
            createSelected: create,
            infoSelected: infoSelected,
            shareSelected: shareQuestion,
            moreSelected: moreQuestion,
            moreMenuSelected: moreMenuSelected,
            userData: user,
            loadingIndicator: activityIndicator.asDriver(),
            deletedQuestoinIndex: deletedQuestionSubject.asDriverOnErrorJustComplete(),
            bannerInfo: bannerInfo,
            filter: filter,
            showHeader: showTableHeader)
    }
    
    private func questionitem(resetPage: Bool = false) -> Observable<[QuestionModel]> {
        if resetPage {
            currentPage = 0
        }
        currentPage += 1
        
        var filteredBy: TanyaKandidatAPI.TanyaListFilter = .userVerifiedAll
        var orderedBy: TanyaKandidatAPI.QuestionOrder = .created
        
        if !self.filterItems.isEmpty {
            let filterByString = filterItems.filter({ (filterItem) -> Bool in
                return filterItem.paramKey == "filter_by"
            }).first?.paramValue
            
            let orderByString = filterItems.filter { (filterItem) -> Bool in
                return filterItem.paramKey == "order_by"
            }.first?.paramValue
            
            filteredBy = TanyaKandidatAPI.TanyaListFilter(rawValue: filterByString ?? "user_verified_all") ?? .userVerifiedAll
            orderedBy = TanyaKandidatAPI.QuestionOrder(rawValue: orderByString ?? "created") ?? .created
            
        }
        
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.getQuestions(page: currentPage, perpage: 10, filteredBy: filteredBy, orderedBy: orderedBy), c: QuestionsResponse.self)
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
            .requestObject(TanyaKandidatAPI.reportQuestion(id: question.id, className: "Question"), c: QuestionOptionResponse.self)
            .map { (response) -> String in
                return response.data.vote.status ? "success report" : response.data.vote.text
            }
            .asObservable()
            .catchErrorJustReturn("Oops something went wrong")
    }
    
    private func deleteQuestion(question: QuestionModel) -> Observable<(question: QuestionModel, status: Bool)> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.deleteQuestion(id: question.id
            ), c: QuestionResponse.self)
            .map({ (response) -> (question: QuestionModel, status: Bool) in
                let questionModel = QuestionModel(question: response.data.question)
                let status = response.data.status
                
                return (questionModel, status)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
    private func voteQuestion(question: QuestionModel) -> Observable<(questionId: String, status: Bool)> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.voteQuestion(id: question.id, className: "Question"), c: QuestionOptionResponse.self)
            .map({ (response) -> (question: String, status: Bool) in
                let questionId = question.id
                let status = response.data.vote.status
                
                return (questionId, status)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "tanya"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
}
