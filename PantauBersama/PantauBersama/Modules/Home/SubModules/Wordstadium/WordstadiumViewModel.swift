//
//  WordstadiumViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class WordstadiumViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let searchTrigger: AnyObserver<Void>
        let profileTrigger: AnyObserver<Void>
        let catatanTrigger: AnyObserver<Void>
        let notificationTrigger: AnyObserver<Void>
        let viewWillAppearTrigger: AnyObserver<Void>
        let tooltipTriigger: AnyObserver<LiniType>
    }
    
    struct Output {
        let searchSelected: Driver<Void>
        let profileSelected: Driver<Void>
        let catatanSelected: Driver<Void>
        let notificationSelected: Driver<Void>
        let userO: Driver<UserResponse>
        let tooltipSelected: Driver<TooltipResult>
    }
    
    let navigator: WordstadiumNavigator
    private let searchSubject = PublishSubject<Void>()
    private let profileSubject = PublishSubject<Void>()
    private let catatanS = PublishSubject<Void>()
    private let notificationS = PublishSubject<Void>()
    private let viewWillppearS = PublishSubject<Void>()
    private let tooltipS = PublishSubject<LiniType>()
    
    init(navigator: WordstadiumNavigator) {
        self.navigator = navigator
        
        input = Input(
            searchTrigger: searchSubject.asObserver(),
            profileTrigger: profileSubject.asObserver(),
            catatanTrigger: catatanS.asObserver(),
            notificationTrigger: notificationS.asObserver(),
            viewWillAppearTrigger: viewWillppearS.asObserver(),
            tooltipTriigger: tooltipS.asObserver()
        )
    
        
        let profile = profileSubject
            .flatMapLatest({ navigator.launchProfile(isMyAccount: true, userId: nil) })
            .asDriver(onErrorJustReturn: ())
        
        let note = catatanS
            .flatMapLatest({ navigator.launchNote() })
            .asDriver(onErrorJustReturn: ())
        
        let search = searchSubject
            .flatMapLatest({ navigator.launchSearch() })
            .asDriver(onErrorJustReturn: ())
        
        let notification = notificationS
            .flatMapLatest({ navigator.launchNotifications() })
            .asDriverOnErrorJustComplete()
        
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let userData = viewWillppearS
            .flatMapLatest({ local })
            .asDriverOnErrorJustComplete()
        
        let tooltip = tooltipS
            .flatMapLatest({ (type) -> Observable<TooltipResult> in
                return navigator.launchTooltip(type: type)
            })
            .asDriverOnErrorJustComplete()
        
//        let tooltip = tooltipS
//            .flatMapLatest({ navigator.launchTooltip() })
//            .asDriverOnErrorJustComplete()
        
        output = Output(searchSelected: search,
                        profileSelected: profile,
                        catatanSelected: note,
                        notificationSelected: notification,
                        userO: userData,
                        tooltipSelected: tooltip
        )
    }
    

}
