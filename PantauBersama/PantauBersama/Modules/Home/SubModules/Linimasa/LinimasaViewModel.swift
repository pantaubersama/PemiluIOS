//
//  LinimasaViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


final class LinimasaViewModel: ViewModelType {

    var input: Input
    var output: Output
    
    struct Input {
        let addTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<Void>
        let refreshTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let filterSelected: Driver<Void>
        let addSelected: Driver<Void>
    }
    
    private let navigator: LinimasaNavigator
    private let addSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        
        input = Input(
            addTrigger: addSubject.asObserver(),
            filterTrigger: filterSubject.asObserver(),
            refreshTrigger: refreshSubject.asObserver()
        )
        
        let filter = filterSubject
            .flatMapLatest{(navigator.launchFilter())}
            .asDriver(onErrorJustReturn: ())
        
        let add = addSubject
            .flatMapLatest({ navigator.launchAddJanji() })
            .asDriver(onErrorJustReturn: ())
        
        output = Output(filterSelected: filter,
                        addSelected: add)
    }
    
}
