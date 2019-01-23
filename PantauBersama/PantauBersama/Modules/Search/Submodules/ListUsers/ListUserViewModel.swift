//
//  ListUserViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import Networking
import RxSwift
import RxCocoa

class ListUserViewModel: ViewModelType {
    struct Input {
        let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
        let itemSelectedI: AnyObserver<IndexPath>
    }
    
    struct Output {
        let searchedUser: Driver<[User]>
        let filter: Driver<Void>
        let itemSelectedO: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    
    private var currentPage = 0
    private let disposeBag = DisposeBag()
    private var filterItems: [PenpolFilterModel.FilterItem] = []
    private let filterSubject = PublishSubject<[PenpolFilterModel.FilterItem]>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    
    init(searchTrigger: PublishSubject<String>, navigator: UserSearchNavigator) {
        input = Input(filterTrigger: filterSubject.asObserver(), itemSelectedI: itemSelectedS.asObserver())
        
        let cachedFilter = PenpolFilterModel.generateUsersFilter()
        cachedFilter.forEach { (filterModel) in
            let selectedItem = filterModel.items.filter({ (filterItem) -> Bool in
                return filterItem.isSelected
            })
            self.filterItems.append(contentsOf: selectedItem)
        }
        
        let searchedUser = searchTrigger
            .flatMapLatest({ self.searchUser(resetPage: true, query: $0) })
            .asDriver(onErrorJustReturn: [])
        
        let filter = filterSubject
            .do(onNext: { [weak self] (filterItems) in
                guard let `self` = self else { return  }
                print("Filter \(filterItems)")
                
                let filter = filterItems.filter({ (filterItem) -> Bool in
                    return filterItem.id.contains("user")
                })
                
                if !filter.isEmpty {
                    self.filterItems = filterItems
                }
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let selected = itemSelectedS
            .withLatestFrom(searchedUser) { (indexPath, items) -> User in
                return items[indexPath.row]
            }
            .flatMapLatest({ navigator.launchProfileUser(isMyAccount: false, userId: $0.id )})
            .asDriverOnErrorJustComplete()
        
        
        output = Output(searchedUser: searchedUser, filter: filter, itemSelectedO: selected)
    }
    
    private func searchUser(resetPage: Bool = false, query: String) -> Observable<[User]> {
         if query.isEmpty {
            currentPage = 0
            return Observable.just([])
        }
        
        if resetPage {
            currentPage = 0
        }
        
        var filteredBy = ""
        if !self.filterItems.isEmpty {
            let filterByString = self.filterItems.filter({ (filterItem) -> Bool in
                return filterItem.paramKey == "filter_by"
            }).first?.paramValue
            
            filteredBy = filterByString ?? "verified_all"
        }
        
        return NetworkService.instance.requestObject(PantauAuthAPI.users(page: currentPage, perPage: 10, query: query, filterBy: PantauAuthAPI.UserListFilter(rawValue: filteredBy) ?? .userVerifiedAll), c: UsersResponse.self)
            .map({ [weak self](response) -> [User] in
                guard let weakSelf = self else { return [] }
                if response.data.users.count == 10 {
                    weakSelf.currentPage += 1
                }
                return response.data.users
            })
            .asObservable()
            .catchErrorJustComplete()
    }
}
