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
    }
    
    struct Output {
        let searchedUser: Driver<[User]>
    }
    
    var input: Input
    var output: Output!
    
    private var currentPage = 0
    
    init(searchTrigger: PublishSubject<String>) {
        input = Input()
        
        let searchedUser = searchTrigger
            .debounce(2, scheduler: MainScheduler.instance)
            .flatMapLatest({ self.searchUser(query: $0) })
            .asDriver(onErrorJustReturn: [])
        
        output = Output(searchedUser: searchedUser)
    }
    
    private func searchUser(resetPage: Bool = false, query: String) -> Observable<[User]> {
        if resetPage {
            currentPage = 0
        }
        currentPage += 1
        
        return NetworkService.instance.requestObject(PantauAuthAPI.users(page: currentPage, perPage: 10, query: query), c: UsersResponse.self)
            .map({ (response) -> [User] in
                return response.data.users
            })
            .asObservable()
            .catchErrorJustComplete()
    }
}
