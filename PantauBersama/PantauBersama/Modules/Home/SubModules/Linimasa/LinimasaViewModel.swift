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
import Networking

final class LinimasaViewModel: ViewModelType {

    var input: Input
    var output: Output
    
    struct Input {
        let addTrigger: AnyObserver<Void>
        let filterTrigger: AnyObserver<Void>
        let refreshTrigger: AnyObserver<Void>
        let profileTrigger: AnyObserver<Void>
        let viewWillAppearTrigger: AnyObserver<Void>
        let catatanTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let filterSelected: Driver<Void>
        let addSelected: Driver<Void>
        let profileSelected: Driver<Void>
        let userO: Driver<UserResponse>
        let catatanSelected: Driver<Void>
    }
    
    let navigator: LinimasaNavigator
    private let addSubject = PublishSubject<Void>()
    private let filterSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let profileSubject = PublishSubject<Void>()
    private let viewWillppearS = PublishSubject<Void>()
    private let catatanS = PublishSubject<Void>()
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        
        input = Input(
            addTrigger: addSubject.asObserver(),
            filterTrigger: filterSubject.asObserver(),
            refreshTrigger: refreshSubject.asObserver(),
            profileTrigger: profileSubject.asObserver(),
            viewWillAppearTrigger: viewWillppearS.asObserver(),
            catatanTrigger: catatanS.asObserver()
        )
        
        let filter = filterSubject
            .flatMapLatest{(navigator.launchFilter())}
            .asDriver(onErrorJustReturn: ())
        
        let add = addSubject
            .flatMapLatest({ navigator.launchAddJanji() })
            .asDriver(onErrorJustReturn: ())
        
        let profile = profileSubject
            .flatMapLatest({ navigator.launchProfile() })
            .asDriver(onErrorJustReturn: ())
        
        let note = catatanS
            .flatMapLatest({ navigator.launchNote() })
            .asDriver(onErrorJustReturn: ())
        
        // MARK
        // Get local user response
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let userData = viewWillppearS
            .flatMapLatest({ local })
            .asDriverOnErrorJustComplete()
        
        output = Output(filterSelected: filter,
                        addSelected: add,
                        profileSelected: profile,
                        userO: userData,
                        catatanSelected: note)
    }
    
}
