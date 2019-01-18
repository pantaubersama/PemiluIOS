//
//  SearchViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class SearchViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
        let searchInputTrigger: AnyObserver<String>
        let loadRecentlyTrigger: AnyObserver<Void>
        let itemSelectedTrigger: AnyObserver<IndexPath>
        let clearRecentSearchTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
        let searchTrigger: PublishSubject<String>
        let recentlySearched: Driver<[String]>
    }
    
    var input: Input
    var output: Output!
    
    let navigator: SearchNavigator

    let searchSubject = PublishSubject<String>()
    private let backSubject = PublishSubject<Void>()
    private let recentlySearchedSubject = PublishSubject<Void>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let clearRecentSearchSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    init(navigator: SearchNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backSubject.asObserver(),
                      searchInputTrigger: searchSubject.asObserver(),
                      loadRecentlyTrigger: recentlySearchedSubject.asObserver(),
                      itemSelectedTrigger: itemSelectedSubject.asObserver(),
                      clearRecentSearchTrigger: clearRecentSearchSubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.finishSearch() })
            .asDriverOnErrorJustComplete()
        
        let recentlySaerched = recentlySearchedSubject
            .flatMapLatest({ _ in Observable.just(UserDefaults.getRecentlySearched() ?? []) })
            .asDriver(onErrorJustReturn: [])
        
        itemSelectedSubject
            .withLatestFrom(recentlySaerched) { (indexPath, items) -> String in
                return items[indexPath.row]
            }
            .bind(to: searchSubject)
            .disposed(by: disposeBag)
        
        clearRecentSearchSubject.flatMapLatest({ _ in Observable.just(UserDefaults.clearRecentlySearched() )})
            .bind(to: input.loadRecentlyTrigger)
            .disposed(by: disposeBag)
        
        
        output = Output(back: back, searchTrigger: searchSubject, recentlySearched: recentlySaerched)
        
        output.searchTrigger
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { (query) in
                UserDefaults.addRecentlySearched(query: query)
            })
            .disposed(by: disposeBag)
    }
}
