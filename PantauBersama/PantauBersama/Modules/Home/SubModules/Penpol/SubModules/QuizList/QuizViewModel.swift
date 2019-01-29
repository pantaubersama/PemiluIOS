//
//  QuizViewModel.swift
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

class QuizViewModel: ViewModelType {
    
    enum QuizOrder: Int {
        case inProgress = 0
        case notParticipating = 1
        case finished = 2
    }
    
    var input: Input
    var output: Output!
    
    struct Input {
        let loadQuizTrigger: AnyObserver<Void>
        let nextPageTrigger: AnyObserver<Void>
        let openQuizTrigger: AnyObserver<QuizModel>
        let shareTrigger: AnyObserver<QuizModel>
        let infoTrigger: AnyObserver<Void>
        let shareTrendTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
        let viewWillAppearTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let openQuizSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareTrendSelected: Driver<Void>
        let laodingIndicator: Driver<Bool>
        let quizzes: BehaviorRelay<[QuizModel]>
        let bannerInfo: Driver<BannerInfo>
        let totalResult: Driver<TrendResponse>
        let filter: Driver<Void>
        let showHeader: Driver<Bool>
    }
    
    private let loadQuizSubject = PublishSubject<Void>()
    private let nextPageSubject = PublishSubject<Void>()
    private let openQuizSubject = PublishSubject<QuizModel>()
    private let shareSubject = PublishSubject<QuizModel>()
    private let infoSubject = PublishSubject<Void>()
    private let shareTrendSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    private let quizRelay = BehaviorRelay<[QuizModel]>(value: [])
    private let viewWillAppearS = PublishSubject<Void>()
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    private let navigator: QuizNavigator
    private var currentPage = 0
    private var filterItems: [PenpolFilterModel.FilterItem] = [] {
        didSet {
            if let filterByString = filterItems.filter({ (filterItem) -> Bool in
                return filterItem.paramKey == "filter_by"
            }).first?.paramValue {
                self.filterOrder = QuizAPI.QuizListFilter(rawValue: filterByString) ?? .all
            } else {
                filterOrder = .all
            }
        }
    }
    private var filterOrder: QuizAPI.QuizListFilter = .all
    
    private let disposeBag = DisposeBag()
    
    let headerViewModel = BannerHeaderViewModel()
    
    private var loadQuizKindOrder = 0
    
    private var searchQuery = ""
    
    init(navigator: PenpolNavigator, searchTrigger: PublishSubject<String>? = nil, showTableHeader: Bool) {
        self.navigator = navigator
        
        input = Input(
            loadQuizTrigger: loadQuizSubject.asObserver(),
            nextPageTrigger: nextPageSubject.asObserver(),
            openQuizTrigger: openQuizSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            infoTrigger: infoSubject.asObserver(),
            shareTrendTrigger: shareTrendSubject.asObserver(),
            filterTrigger: filterSubject.asObserver(),
            viewWillAppearTrigger: viewWillAppearS.asObserver())
        
        searchTrigger?.asObserver()
            .do(onNext: { [weak self](query) in
                self?.searchQuery = query
            })
            .mapToVoid()
            .bind(to: input.loadQuizTrigger)
            .disposed(by: disposeBag)
        
        let openQuiz = openQuizSubject
            .flatMapLatest({navigator.openQuiz(quiz: $0)})
            .asDriver(onErrorJustReturn: ())
        let shareQuiz = shareSubject
            .flatMapLatest({navigator.shareQuiz(quiz: $0)})
            .asDriver(onErrorJustReturn: ())
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchPenpolBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        let shareTrend = shareTrendSubject
            .flatMapLatest({navigator.shareTrend()})
            .asDriver(onErrorJustReturn: ())
        
        let bannerInfo = viewWillAppearS
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        let totalResult = Observable.combineLatest(viewWillAppearS.asObservable(), loadQuizSubject.asObservable())
            .flatMapLatest({ _ in self.totalResult() })
            .asDriverOnErrorJustComplete()
        
        let cachedFilter = PenpolFilterModel.generateQuizFilter()
        cachedFilter.forEach { (filterModel) in
            let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                return filterItem.isSelected
            })
            self.filterItems.append(contentsOf: selectedItem)
        }
        
        if let filterByString = filterItems.filter({ (filterItem) -> Bool in
            return filterItem.paramKey == "filter_by"
        }).first?.paramValue {
            self.filterOrder = QuizAPI.QuizListFilter(rawValue: filterByString) ?? .all
        }
        
        
        let filter = filterSubject
            .do(onNext: { [weak self](filterItems) in
                guard let weakSelf = self else { return }
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("quiz")
                })
                
                weakSelf.filterItems = filter
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        Observable.combineLatest(viewWillAppearS.asObservable(), loadQuizSubject.asObservable())
            .flatMapLatest({ [weak self](query) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                weakSelf.loadQuizKindOrder = 0
                return weakSelf.quizItems(resetPage: true)
                    .map { [weak self](response) -> [QuizModel] in
                        guard let weakSelf = self else { return [] }
                        return weakSelf.generateQuizzes(from: response)
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](quizzes) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                if quizzes.isEmpty {
                    weakSelf.loadQuizKindOrder += 1
                    return weakSelf.quizItems(resetPage: true)
                        .map { [weak self](response) -> [QuizModel] in
                            guard let weakSelf = self else { return [] }
                            return weakSelf.generateQuizzes(from: response)
                        }
                        .trackActivity(weakSelf.activityIndicator)
                        .trackError(weakSelf.errorTracker)
                        .asObservable()
                        .catchErrorJustReturn([])
                }
                
                return Observable.just(quizzes)
            })
            .flatMapLatest({ [weak self](quizzes) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                if quizzes.isEmpty {
                    weakSelf.loadQuizKindOrder += 1
                    return weakSelf.quizItems(resetPage: true)
                        .map { [weak self](response) -> [QuizModel] in
                            guard let weakSelf = self else { return [] }
                            return weakSelf.generateQuizzes(from: response)
                        }
                        .trackActivity(weakSelf.activityIndicator)
                        .trackError(weakSelf.errorTracker)
                        .asObservable()
                        .catchErrorJustReturn([])
                }
                
                return Observable.just(quizzes)
            })
            .bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.quizRelay.accept(loadedItem)
            }
            .disposed(by: disposeBag)
        
        nextPageSubject
            .flatMapLatest({ [weak self](_) -> Observable<[QuizModel]> in
                // in progress
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.quizItems()
                    .map { [weak self](response) -> [QuizModel] in
                        guard let weakSelf = self else { return [] }
                        return weakSelf.generateQuizzes(from: response)
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](quizzes) -> Observable<[QuizModel]> in
                // not participating
                guard let weakSelf = self else { return Observable.empty() }
                if quizzes.isEmpty && weakSelf.filterOrder == .all {
                    weakSelf.loadQuizKindOrder += 1
                    return weakSelf.quizItems(resetPage: true)
                        .map { [weak self](response) -> [QuizModel] in
                            guard let weakSelf = self else { return [] }
                            return weakSelf.generateQuizzes(from: response)
                        }
                        .trackActivity(weakSelf.activityIndicator)
                        .trackError(weakSelf.errorTracker)
                        .asObservable()
                        .catchErrorJustReturn([])
                }
                
                return Observable.just(quizzes)
            })
            .flatMapLatest({ [weak self](quizzes) -> Observable<[QuizModel]> in
                // finished
                guard let weakSelf = self else { return Observable.empty() }
                if quizzes.isEmpty && weakSelf.filterOrder == .all {
                    weakSelf.loadQuizKindOrder += 1
                    return weakSelf.quizItems(resetPage: true)
                        .map { [weak self](response) -> [QuizModel] in
                            guard let weakSelf = self else { return [] }
                            return weakSelf.generateQuizzes(from: response)
                        }
                        .trackActivity(weakSelf.activityIndicator)
                        .trackError(weakSelf.errorTracker)
                        .asObservable()
                        .catchErrorJustReturn([])
                }
                
                return Observable.just(quizzes)
            })
            .filter({ !$0.isEmpty })
            .bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                var newItem = weakSelf.quizRelay.value
                newItem.append(contentsOf: loadedItem)
                weakSelf.quizRelay.accept(newItem)
            }
            .disposed(by: disposeBag)
        
        let showTableHeader = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        output = Output(
            openQuizSelected: openQuiz,
            shareSelected: shareQuiz,
            infoSelected: infoSelected,
            shareTrendSelected: shareTrend,
            laodingIndicator: activityIndicator.asDriver(),
            quizzes: quizRelay,
            bannerInfo: bannerInfo,
            totalResult: totalResult,
            filter: filter,
            showHeader: showTableHeader)
    }
    
    private func quizItems(resetPage: Bool = false) -> Observable<QuizzesResponse> {
        if resetPage {
            currentPage = 0
        }
        
        currentPage += 1
        
        if filterOrder == .notParticipating {
            return NetworkService.instance.requestObject(QuizAPI.getQuizzes(query: self.searchQuery, page: currentPage, perPage: 30), c: QuizzesResponse.self)
                .asObservable()
        } else if filterOrder != .all {
            return NetworkService.instance.requestObject(QuizAPI.getParticipatedQuizzes(query: self.searchQuery, page: currentPage, perPage: 30, filterBy: filterOrder), c: QuizzesResponse.self)
                .asObservable()
        }
        
        switch loadQuizKindOrder {
        case 0:
            return NetworkService.instance.requestObject(QuizAPI.getParticipatedQuizzes(query: self.searchQuery, page: currentPage, perPage: 30, filterBy: .inProgress), c: QuizzesResponse.self)
                .asObservable()
        case 1:
            return NetworkService.instance.requestObject(QuizAPI.getQuizzes(query: self.searchQuery, page: currentPage, perPage: 30), c: QuizzesResponse.self)
                .asObservable()
        case 2:
            return NetworkService.instance.requestObject(QuizAPI.getParticipatedQuizzes(query: self.searchQuery, page: currentPage, perPage: 30, filterBy: .finished), c: QuizzesResponse.self)
                .asObservable()
        default:
            return Observable<QuizzesResponse>.empty()
        }
    }
    
    private func generateQuizzes(from quizResponse: QuizzesResponse) -> [QuizModel] {
        return quizResponse.data.quizzes.map({ (quizResponse) -> QuizModel in
            return QuizModel(quiz: quizResponse)
        })
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "kuis"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
    private func totalResult() -> Observable<TrendResponse> {
        return NetworkService.instance
            .requestObject(
                QuizAPI.getTotalResult(),
                c: BaseResponse<TrendResponse>.self
            )
            .map{ ($0.data) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
