//
//  QuestionListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class QuestionListViewModel: IQuestionListViewModel, IQuestionListViewModelInput, IQuestionListViewModelOutput{
    
    var input: IQuestionListViewModelInput { return self }
    var output: IQuestionListViewModelOutput { return self }
    
    var refreshI: AnyObserver<String>
    var nextPageI: AnyObserver<Void>
    var moreI: AnyObserver<QuestionModel>
    var moreMenuI: AnyObserver<QuestionType>
    var filterI: AnyObserver<[PenpolFilterModel.FilterItem]>
    var shareQuestionI: AnyObserver<QuestionModel>
    var voteI: AnyObserver<QuestionModel>
    var unVoteI: AnyObserver<QuestionModel>
    var createI: AnyObserver<Void>
    var loadCreatedI: AnyObserver<Void>
    var itemSelectedI: AnyObserver<IndexPath>
    
    var items: Driver<[ICellConfigurator]>!
    var error: Driver<Error>!
    var moreSelectedO: Driver<QuestionModel>!
    var moreMenuSelectedO: Driver<String>!
    var shareSelectedO: Driver<Void>!
    var filterO: Driver<Void>!
    var bannerO: Driver<BannerInfo>!
    var bannerSelectedO: Driver<Void>!
    var userDataO: Driver<UserResponse>!
    var deleteO: Driver<Int>!
    var createO: Driver<Void>!
    var showHeaderO: Driver<Bool>!
    var itemSelectedO: Driver<Void>!
    
    private let refreshSubject = PublishSubject<String>()
    private let moreSubject = PublishSubject<QuestionModel>()
    private let moreMenuSubject = PublishSubject<QuestionType>()
    private let nextSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    private let createSubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<QuestionModel>()
    private let voteSubject = PublishSubject<QuestionModel>()
    private let unVoteSubject = PublishSubject<QuestionModel>()
    private let deletedQuestionSubject = PublishSubject<Int>()
    private let questionRelay = BehaviorRelay<[QuestionModel]>(value: [])
    private let loadCreated = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    private(set) var disposeBag = DisposeBag()
    private var searchQuery = ""
    
    init(navigator: PenpolNavigator, searchTrigger: PublishSubject<String>? = nil, loadCreatedTrigger: PublishSubject<Void>? = nil, showTableHeader: Bool) {
        refreshI = refreshSubject.asObserver()
        nextPageI = nextSubject.asObserver()
        moreI = moreSubject.asObserver()
        moreMenuI = moreMenuSubject.asObserver()
        shareQuestionI = shareSubject.asObserver()
        voteI = voteSubject.asObserver()
        unVoteI = unVoteSubject.asObserver()
        filterI = filterSubject.asObserver()
        createI = createSubject.asObserver()
        loadCreatedI = loadCreated.asObserver()
        itemSelectedI = itemSelectedS.asObserver()
        
        if let externalLoadTrigger = loadCreatedTrigger {
            externalLoadTrigger.flatMapLatest { [unowned self](_) -> Observable<[QuestionModel]> in
                return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), filteredBy: "user_verified_all", orderedBy: "created_at", query: "")
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustReturn([])
                }.filter { (questions) -> Bool in
                    return !questions.isEmpty
                }.bind { [weak self](loadedItem) in
                    guard let weakSelf = self else { return }
                    weakSelf.questionRelay.accept(loadedItem)
                }.disposed(by: disposeBag)
        }
        
        error = errorTracker.asDriver()
        
        searchTrigger?.asObserver()
            .do(onNext: { [weak self](query) in
                self?.searchQuery = query
            })
            .bind(to: refreshI)
            .disposed(by: disposeBag)
        
        loadCreated.flatMapLatest { [unowned self](_) -> Observable<[QuestionModel]> in
            return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), filteredBy: "user_verified_all", orderedBy: "created_at", query: "")
                .trackError(self.errorTracker)
                .trackActivity(self.activityIndicator)
                .catchErrorJustReturn([])
            }.filter { (questions) -> Bool in
                return !questions.isEmpty
            }.bind { [weak self](loadedItem) in
                guard let weakSelf = self else { return }
                weakSelf.questionRelay.accept(loadedItem)
            }.disposed(by: disposeBag)
        
        // MARK:
        // Get question pagination
        refreshSubject.startWith("").flatMapLatest { [unowned self] (query) -> Observable<[QuestionModel]> in
            self.filterItems.removeAll()
            let cachedFilter = PenpolFilterModel.generateQuestionFilter()
            cachedFilter.forEach { (filterModel) in
                let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                    return filterItem.isSelected
                })
                self.filterItems.append(contentsOf: selectedItem)
            }
            
            var filteredBy = self.filterItems.filter({ $0.paramKey == "filter_by"}).first?.paramValue
            var orderedBy = self.filterItems.filter({ $0.paramKey == "order_by"}).first?.paramValue
            
            if !self.filterItems.isEmpty {
                let filterByString = self.filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.paramKey == "filter_by"
                }).first?.paramValue
                
                let orderByString = self.filterItems.filter { (filterItem) -> Bool in
                    return filterItem.paramKey == "order_by"
                    }.first?.paramValue
                
                filteredBy = filterByString ?? "user_verified_all"
                orderedBy = orderByString ?? "created_at"
            }
                
            return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), filteredBy: filteredBy ?? "user_verified_all", orderedBy: orderedBy ?? "cached_votes_up", query: query)
                .trackError(self.errorTracker)
                .trackActivity(self.activityIndicator)
                .catchErrorJustReturn([])
        }
        .filter { (questions) -> Bool in
            return !questions.isEmpty
        }.bind { [weak self](loadedItem) in
            guard let weakSelf = self else { return }
            weakSelf.questionRelay.accept(loadedItem)
        }.disposed(by: disposeBag)
        
        // MARK:
        // Map question response to cell list
        items = questionRelay.asDriver(onErrorJustReturn: [])
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (question) -> ICellConfigurator in
                    return AskViewCellConfigured(item: AskViewCell.Input(viewModel: self, question: question))
                })
        }
        
        // MARK
        // Selected Item
        let item = questionRelay.asDriverOnErrorJustComplete()
        itemSelectedO = itemSelectedS
            .withLatestFrom(item) { (indexPath, items) -> QuestionModel in
                return items[indexPath.row]
            }
            .flatMapLatest({ navigator.launchDetailAsk(data: $0.id) })
            .asDriverOnErrorJustComplete()
        
        
    
        moreSelectedO = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        moreMenuSelectedO = moreMenuSubject
            .flatMapLatest({ [weak self](type) -> Observable<String> in
                guard let weakSelf = self else { return Observable.empty() }
                switch type {
                case .bagikan(let question):
                    let contentToShare = question.id
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
                            return
                        })
                        .map({ (result) -> String in
                            return result.status ? "delete succeeded" : "delete failed"
                        })
                case .laporkan(let question):
                    return weakSelf.reportQuestion(question: question)
                case .salin(let question):
                    let data = "\(AppContext.instance.infoForKey("URL_WEB"))/share/tanya/\(question.id)"
                    data.copyToClipboard()
                    return Observable.just("Tautan telah tersalin")
                }
            })
            .asDriverOnErrorJustComplete()
        
        shareSelectedO = shareSubject
            .flatMapLatest({navigator.shareQuestion(question: $0.id)})
            .asDriver(onErrorJustReturn: ())
        
        filterO = filterSubject
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("question")
                })
                
                if !filter.isEmpty {
                    self.filterItems = filterItems
                }
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        createO = createSubject
            .flatMapLatest({ navigator.launchCreateAsk(loadCreatedTrigger: self.loadCreatedI) })
            .asDriver(onErrorJustReturn: ())
        
        bannerO = refreshSubject.startWith("")
            .mapToVoid()
            .flatMapLatest({ self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        bannerSelectedO = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchPenpolBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        showHeaderO = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        // MARK: Fetch User cloud because for first time
//        let cloud = NetworkService.instance.requestObject(
//            PantauAuthAPI.me,
//            c: BaseResponse<UserResponse>.self)
//            .map({ $0.data })
//            .do(onSuccess: { (response) in
//                AppState.saveMe(response)
//            })
//            .trackError(errorTracker)
//            .trackActivity(activityIndicator)
//            .asObservable()
//            .catchErrorJustComplete()
        let local: Observable<UserResponse> = AppState.local(key: .me)
        userDataO = refreshSubject.startWith("").mapToVoid()
            .flatMapLatest({ local })
            .asDriverOnErrorJustComplete()
        
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
        
        
        unVoteSubject
            .flatMapLatest({ self.deleteVoteQuestion(question: $0) })
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
                updateQuestion.isLiked = false
                updateQuestion.likeCount = updateQuestion.likeCount - 1
                currentValue.remove(at: index)
                currentValue.insert(updateQuestion, at: index)
                weakSelf.questionRelay.accept(currentValue)
            }
            .disposed(by: disposeBag)

    }
    
    func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        filteredBy: String,
        orderedBy: String,
        query: String) ->
        Observable<Page<[QuestionModel]>> {
            return NetworkService.instance
                .requestObject(TanyaKandidatAPI.getQuestions(query: query, page: batch.page, perpage: batch.limit, filteredBy: filteredBy, orderedBy: orderedBy), c: QuestionsResponse.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[QuestionModel]>> in
                    return self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, filteredBy: filteredBy, orderedBy: orderedBy, query: self.searchQuery)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
}
