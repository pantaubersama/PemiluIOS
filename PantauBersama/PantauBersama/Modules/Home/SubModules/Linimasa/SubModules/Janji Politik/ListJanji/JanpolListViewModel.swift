//
//  JanpolListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class JanpolListViewModel: IJanpolListViewModel, IJanpolListViewModelInput, IJanpolListViewModelOutput {
    
    var input: IJanpolListViewModelInput { return self }
    var output: IJanpolListViewModelOutput { return self }
    
    var refreshI: AnyObserver<String>
    var nextPageI: AnyObserver<Void>
    var shareJanjiI: AnyObserver<JanjiPolitik>
    var moreI: AnyObserver<Int>
    var moreMenuI: AnyObserver<JanjiType>
    var itemSelectedI: AnyObserver<IndexPath>
    var filterI: AnyObserver<[PenpolFilterModel.FilterItem]>
    var createI: AnyObserver<Void>
    var viewWillAppearI: AnyObserver<Void>
    
    var items: Driver<[ICellConfigurator]>!
    var error: Driver<Error>!
    var moreSelectedO: Driver<JanjiPolitik>!
    var moreMenuSelectedO: Driver<String>!
    var itemSelectedO: Driver<Void>!
    var shareSelectedO: Driver<Void>!
    var filterO: Driver<Void>!
    var bannerO: Driver<BannerInfo>!
    var bannerSelectedO: Driver<Void>!
    var showHeaderO: Driver<Bool>!
    var createO: Driver<CreateJanjiPolitikResponse>!
    var userO: Driver<UserResponse>!
    
    private let refreshSubject = PublishSubject<String>()
    private let moreSubject = PublishSubject<Int>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<JanjiPolitik>()
    private let nextSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    private let createSubject = PublishSubject<Void>()
    private let viewWillppearSubject = PublishSubject<Void>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    private var searchQuery: String?
    private let janpolItems = BehaviorRelay<[JanjiPolitik]>(value: [])
    private(set) var disposeBag = DisposeBag()
    
    init(navigator: IJanpolNavigator, searchTrigger: PublishSubject<String>? = nil, showTableHeader: Bool) {
        refreshI = refreshSubject.asObserver()
        nextPageI = nextSubject.asObserver()
        moreI = moreSubject.asObserver()
        moreMenuI = moreMenuSubject.asObserver()
        shareJanjiI = shareSubject.asObserver()
        itemSelectedI = itemSelectedSubject.asObserver()
        filterI = filterSubject.asObserver()
        createI = createSubject.asObserver()
        viewWillAppearI = viewWillppearSubject.asObserver()
        
        error = errorTracker.asDriver()
    
        
        let cachedFilter = PenpolFilterModel.generateJanjiFilter()
        cachedFilter.forEach { (filterModel) in
            let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                return filterItem.isSelected || filterItem.type == .text
            })
            self.filterItems.append(contentsOf: selectedItem)
        }
        
        refreshSubject.flatMapLatest { [unowned self] (query) -> Observable<[JanjiPolitik]> in
                let cid = self.filterItems.filter({ $0.paramKey == "cluster_id"}).first?.paramValue
                let filter = self.filterItems.filter({ $0.paramKey == "filter_by"}).first?.paramValue
                
                if cid != "" {
                    return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), cid: cid ?? "", filter: filter ?? "", query: self.searchQuery ?? query)
                        .trackError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                        .catchErrorJustReturn([])
                } else {
                    return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable(), cid: cid ?? "", filter: filter ?? "", query: self.searchQuery ?? query)
                        .trackError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                        .catchErrorJustReturn([])
                }
            }
            .bind { [weak self](items) in
                guard let weakSelf = self else { return }
                weakSelf.janpolItems.accept(items)
            }.disposed(by: disposeBag)
        
        // MARK:
        // Map feeds response to cell list
        items = janpolItems.asDriver(onErrorJustReturn: [])
            .map { (list) -> [ICellConfigurator] in
                return list.map({ (janpol) -> ICellConfigurator in
                    return LinimasaJanjiCellConfigured(item: LinimasaJanjiCell.Input(viewModel: self, janpol: janpol))
                })
        }
        
        
        itemSelectedO = itemSelectedSubject
            .withLatestFrom(janpolItems) { (indexPath, items) -> JanjiPolitik in
                return items[indexPath.row]
            }
            .flatMapLatest({ navigator.launchJanjiDetail(data: $0) })
            .asDriverOnErrorJustComplete()
    
        
        moreSelectedO = moreSubject
            .asObservable()
            .withLatestFrom(janpolItems) { (row, janpols) in
                return janpols[row]
            }
            .asDriverOnErrorJustComplete()
        
        shareSelectedO = shareSubject
            .flatMapLatest({ navigator.shareJanji(data: $0) })
            .asDriver(onErrorJustReturn: ())
        
        moreMenuSelectedO = moreMenuSubject
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .bagikan(let data):
                    return navigator.shareJanji(data: data)
                        .map({ (_) -> String in
                            return ""
                        })
                case .salin(let data):
                    let urlSalin = "\(AppContext.instance.infoForKey("URL_WEB"))/share/janjipolitik/\(data.id)"
                    urlSalin.copyToClipboard()
                    return Observable.just("Tautan telah tersalin")
                case .hapus(let id):
                    return self.delete(id: id)
                        .do(onNext: { (result) in
                            var currentItems = self.janpolItems.value
                            guard let index = currentItems.index(where: { item -> Bool in
                                return item.id == id
                            }) else {
                                return
                            }
                            
                            currentItems.remove(at: index)
                            self.janpolItems.accept(currentItems)
                            return
                        })
                        .map({ (result) -> String in
                            return result.data.message
                        })
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        filterO = filterSubject
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("janji")
                })
                
                
                self.filterItems = filter
                
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        searchTrigger?.asObserver()
            .do(onNext: { [unowned self](query) in
                self.searchQuery = query
            })
            .bind(to: refreshI)
            .disposed(by: disposeBag)
        
        bannerO = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()

        bannerSelectedO = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchJanpolBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        showHeaderO = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        createO = createSubject
            .flatMapLatest({ navigator.launchAddJanji() })
            .flatMapLatest { (type) -> Driver<CreateJanjiPolitikResponse> in
                switch type {
                case .cancel:
                    return Driver.empty()
                case .result(let result):
                    return Driver.just(result)
                }
            }.asDriverOnErrorJustComplete()
        
        //get local user
        let local: Observable<UserResponse> = AppState.local(key: .me)
        userO = viewWillppearSubject
            .flatMapLatest({ local })
            .asDriverOnErrorJustComplete()

        
    }
    
    func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        cid: String,
        filter: String,
        query: String) ->
        Observable<Page<[JanjiPolitik]>> {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getJanjiPolitiks(query: query, cid: cid, filter: filter, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<JanjiPolitikResponse>.self)
                .map({ self.transformToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[JanjiPolitik]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, cid: cid, filter: filter, query: query)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "janji politik"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }

    
}

