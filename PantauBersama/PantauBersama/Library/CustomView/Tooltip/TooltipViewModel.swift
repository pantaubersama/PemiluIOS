//
//  TooltipViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

enum TooltipResult {
    case selected
    case cancel
}

class TooltipViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let challengeI: AnyObserver<Void>
        let debatDoneI: AnyObserver<Void>
        let comingSoonI: AnyObserver<Void>
        let debatLiveI: AnyObserver<Void>
        let createTantanganI: AnyObserver<Void>
        let cancelI: AnyObserver<Void>
    }
    
    struct Output {
        let actionsSelected: Driver<TooltipResult>
    }
    
    private var navigator: TooltipNavigator
    private let challengeS = PublishSubject<Void>()
    private let debatDoneS = PublishSubject<Void>()
    private let comingSoonS = PublishSubject<Void>()
    private let debatLiveS = PublishSubject<Void>()
    private let createTantanganS = PublishSubject<Void>()
    private let cancelS = PublishSubject<Void>()
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: TooltipNavigator) {
        self.navigator = navigator
        
        input = Input(challengeI: challengeS.asObserver(),
                      debatDoneI: debatDoneS.asObserver(),
                      comingSoonI: comingSoonS.asObserver(),
                      debatLiveI: debatLiveS.asObserver(),
                      createTantanganI: createTantanganS.asObserver(),
                      cancelI: cancelS.asObserver())
        
        
        let challenge = challengeS
            .flatMapLatest({ navigator.launchChallenge() })
        
        let debatDone = debatDoneS
            .flatMapLatest({ navigator.launchDebatLive() })
        
        let comingSoon = comingSoonS
            .flatMapLatest({ navigator.launchComingSoon() })
        
        let debatLive = debatLiveS
            .flatMapLatest({ navigator.launchDebatLive() })
        
        let createTantangan = createTantanganS
            .flatMapLatest({ navigator.launchTantangan() })
        
        let cancel = cancelS
            .flatMapLatest({ navigator.back() })
        
        
        let actionSelected = Observable.merge(challenge, debatDone, comingSoon, debatLive, createTantangan, cancel)
            .take(1)
            .map({ TooltipResult.selected })
            .asDriverOnErrorJustComplete()
        
        output = Output(actionsSelected: actionSelected)
    }
}
