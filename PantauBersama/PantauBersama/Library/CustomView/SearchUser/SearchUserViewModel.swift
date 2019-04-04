//
//  SearchUserViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

struct SearchUserModel {
    let id: String?
    let screenName: String? // or username
    let fullName: String?
    let avatar: String?
}

enum SearchUserResult {
    case cancel
    case oke(data: SearchUserModel)
}


final class SearchUserViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    
    struct Input {
        let cancelI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
        let queryI: AnyObserver<String>
        let refreshI: AnyObserver<Void>
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let actionSelected: Driver<SearchUserResult>
        let itemsO: Driver<[SearchUserModel]>
    }
    
    private let cancelS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let queryS = PublishSubject<String>()
    private let refreshS = PublishSubject<Void>()
    private let nextS = PublishSubject<Void>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private var type: SearchUserType
    
    init(type: SearchUserType) {
        self.type = type
        
        input = Input(cancelI: cancelS.asObserver(),
                      itemSelectedI: itemSelectedS.asObserver(),
                      queryI: queryS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      nextI: nextS.asObserver())
        
        let query = queryS
            .startWith("")
        
        let refreshWithLatestQuery = refreshS
            .withLatestFrom(query)
        
        let item = Observable.merge(query, refreshWithLatestQuery)
            .flatMapLatest { [weak self] (s) -> Observable<[SearchUserModel]> in
                switch type {
                case .userSymbolic:
                    guard let `self` = self else { return Observable.empty() }
                    return self.paginateItemsSymbolic(nextBatchTrigger: self.nextS, q: s)
                        .trackError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                        .asObservable()
                        .map({ (list) -> [SearchUserModel] in
                            return list.map({ (user) -> SearchUserModel in
                                return SearchUserModel(id: user.id,
                                                       screenName: user.username,
                                                       fullName: user.fullName,
                                                       avatar: user.avatar.thumbnail.url)
                            })
                        })
                case .userTwitter:
                    guard let `self` = self else { return Observable.empty() }
                    return self.fetchTwitterUsername(q: s, page: 1, perPage: 50)
                        .trackError(self.errorTracker)
                        .trackActivity(self.activityIndicator)
                        .asObservable()
                        .map({ (list) -> [SearchUserModel] in
                            return list.map({ (user) -> SearchUserModel in
                                return SearchUserModel(id: "\(user.id)",
                                                       screenName: user.screenName,
                                                       fullName: user.name,
                                                       avatar: user.profileImage)
                            })
                        })

                    
                default:
                    return Observable.empty()
                }
        }.asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedS
            .withLatestFrom(item) { (indexPath, model) in
                return model[indexPath.row]
            }
            .map({ SearchUserResult.oke(data: $0) })
        
        
        let cancel = cancelS
            .map({ SearchUserResult.cancel })
        
        let action = Observable.merge(itemSelected, cancel)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        
        output = Output(actionSelected: action,
                        itemsO: item)
        
    }
    
    private func paginateItemsSymbolic(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>,
        q: String) -> Observable<[User]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, q: q)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        q: String) -> Observable<Page<[User]>> {
        return NetworkService.instance
            .requestObject(PantauAuthAPI.users(page: batch.page,
                                               perPage: batch.limit,
                                               query: q,
                                               filterBy: PantauAuthAPI.UserListFilter.userVerifiedAll)
                , c: UsersResponse.self)
            .map({ self.transformToPage(response: $0, batch: batch) })
            .asObservable()
            .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                return result.batch.next().hasNextPage
            }, nextPageFactory: { (result) -> Observable<Page<[User]>> in
                self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, q: q)
            })
            .share(replay: 1, scope: .whileConnected)
        
    }
    
    private func transformToPage(response: UsersResponse, batch: Batch) -> Page<[User]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[User]>(
            item: response.data.users,
            batch: nextBatch
        )
    }
    
    private func fetchTwitterUsername(q: String, page: Int, perPage: Int) -> Observable<[TwitterUsername]> {
        if q == "" {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getTwitterUsername(q: "a", page: page, perPage: perPage)
                    , c: BaseResponse<TwitterUsernameResponses>.self)
                .map({ $0.data.users })
                .asObservable()
                .share(replay: 1, scope: .whileConnected)
        } else {
            return NetworkService.instance
                .requestObject(LinimasaAPI.getTwitterUsername(q: q, page: page, perPage: perPage)
                    , c: BaseResponse<TwitterUsernameResponses>.self)
                .map({ $0.data.users })
                .asObservable()
                .share(replay: 1, scope: .whileConnected)
        }
    }
}
