//
//  KategoriClusterViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

class KategoriClusterViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let queryI: AnyObserver<String>
        let nextI: AnyObserver<Void>
        let addI: AnyObserver<Void>
        let refreshI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<String>
        let itemSelectedI: AnyObserver<IndexPath>
    }
    
    struct Output {
        let itemsO: Driver<[String]>
        let addO: Driver<AddKategoriResult>
        let resultO: Driver<ResultCategory>
    }
    
    private let backS = PublishSubject<Void>()
    private var navigator: KategoriClusterProtocol
    private let queryS = PublishSubject<String>()
    private let nextS = PublishSubject<Void>()
    private let addS = PublishSubject<Void>()
    private let refreshS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<String>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: KategoriClusterProtocol) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver(),
                      queryI: queryS.asObserver(),
                      nextI: nextS.asObserver(),
                      addI: addS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      itemSelectedI: itemSelectedS.asObserver())
        
        let query = queryS
            .startWith((""))
        
        let refreshWithLatestQuery = refreshS
            .withLatestFrom(query)
        
        let categories = Observable.merge(query, refreshWithLatestQuery, viewWillAppearS.asObservable())
            .flatMapLatest { [weak self] (s) -> Observable<[ICategories]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), q: s)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }
        
        let categoiesCell = categories
            .map { (list) -> [String] in
                return list.map({ (categories) -> String in
                    return categories.name ?? ""
                })
        }
        
        let add = addS
            .flatMapLatest({ navigator.launchAdd() })
            .do(onNext: { (result) in
                switch result {
                case .ok: print("Created Kategory ")
                default: break
                }
            })
        
        
        let itemSelected = itemSelectedS
            .withLatestFrom(categories) { (indexPath, category) in
                return category[indexPath.row]
            }
            .map({ ResultCategory.done(data: $0 )})
        
        let back = backS
            .map({ ResultCategory.cancel })
        
        let result = Observable.merge(itemSelected, back)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        
        output = Output(itemsO: categoiesCell.asDriver(onErrorJustReturn: []),
                        addO: add.asDriverOnErrorJustComplete(),
                        resultO: result)
        
    }
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, q: String) -> Observable<[ICategories]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, q: q)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>, q: String) ->
        Observable<Page<[ICategories]>> {
            return NetworkService.instance
                .requestObject(PantauAuthAPI.categories(q: q, page: batch.page, perPage: batch.limit),
                               c: BaseResponse<CategoriesResponse>.self)
                .map({ self.transfromToPage(response: $0, batch: batch) })
                .asObservable()
                .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                    return result.batch.next().hasNextPage
                }, nextPageFactory: { (result) -> Observable<Page<[ICategories]>> in
                    self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, q: q)
                })
                .share(replay: 1, scope: .whileConnected)
            
    }
    
    private func transfromToPage(response: BaseResponse<CategoriesResponse>, batch: Batch) -> Page<[ICategories]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ICategories]>(
        item: response.data.categories,
        batch: nextBatch)
        
    }
}
