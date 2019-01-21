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
    
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    private let navigator: QuizNavigator
    private var currentPage = 0
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    
    private let disposeBag = DisposeBag()
    
    let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: PenpolNavigator, showTableHeader: Bool) {
        self.navigator = navigator
        
        input = Input(
            loadQuizTrigger: loadQuizSubject.asObserver(),
            nextPageTrigger: nextPageSubject.asObserver(),
            openQuizTrigger: openQuizSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            infoTrigger: infoSubject.asObserver(),
            shareTrendTrigger: shareTrendSubject.asObserver(),
            filterTrigger: filterSubject.asObserver())
        
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
        
        let bannerInfo = loadQuizSubject
            .flatMapLatest({ self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        let totalResult = loadQuizSubject
            .flatMapLatest({ self.totalResult() })
            .asDriverOnErrorJustComplete()
        
        let cachedFilter = PenpolFilterModel.generateQuizFilter()
        cachedFilter.forEach { (filterModel) in
            let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                return filterItem.isSelected
            })
            self.filterItems.append(contentsOf: selectedItem)
        }
        
        
        let filter = filterSubject
            .do(onNext: { [weak self](filterItems) in
                guard let weakSelf = self else { return }
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("quiz")
                })
                
                if !filter.isEmpty {
                    weakSelf.filterItems = filterItems
                }
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        loadQuizSubject
            .flatMapLatest({ [weak self](_) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.quizItems(resetPage: true)
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
            })
            .bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.quizRelay.accept(loadedItem)
            }
            .disposed(by: disposeBag)
        
        nextPageSubject
            .flatMapLatest({ [weak self](_) -> Observable<[QuizModel]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.quizItems()
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
    
    private func quizItems(resetPage: Bool = false) -> Observable<[QuizModel]> {
        if resetPage {
            currentPage = 0
        }
        
        var filteredBy: QuizAPI.QuizListFilter = .finished
        
        if !self.filterItems.isEmpty {
            let filterByString = filterItems.filter({ (filterItem) -> Bool in
                return filterItem.paramKey == "filter_by"
            }).first?.paramValue
            
            filteredBy = QuizAPI.QuizListFilter(rawValue: filterByString ?? "all") ?? .all
        }
        
        currentPage += 1
        return NetworkService.instance.requestObject(QuizAPI.getParticipatedQuizzes(query: "", page: currentPage, perPage: 10, filterBy: filteredBy), c: QuizzesResponse.self)
            .map { [weak self](response) -> [QuizModel] in
                guard let weakSelf = self else { return [] }
                return weakSelf.generateQuizzes(from: response)
            }
            .asObservable()
            .catchErrorJustReturn([])
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
