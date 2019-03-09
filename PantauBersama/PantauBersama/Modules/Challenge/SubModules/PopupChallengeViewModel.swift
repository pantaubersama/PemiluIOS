//
//  PopupChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

enum PopupChallengeType {
    case refuseOpen
    case acceptOpen
    case acceptOpponentOpen(idAudience: String) // for My Challenge
    case refuseDirect
    case acceptDirect
    case `default`
}

class PopupChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let cancelI: AnyObserver<Void>
        let acceptI: AnyObserver<Void>
        let reasonI: AnyObserver<String>
    }
    
    struct Output {
        let actionSelected: Driver<PopupChallengeResult>
    }
    
    private var navigator: PopupChallengeNavigator
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let cancelS = PublishSubject<Void>()
    private let acceptS = PublishSubject<Void>()
    private let reasonS = PublishSubject<String>()
    
    init(navigator: PopupChallengeNavigator) {
        self.navigator = navigator
        
        input = Input(cancelI: cancelS.asObserver(),
                      acceptI: acceptS.asObserver(),
                      reasonI: reasonS.asObserver())
        
        let cancel = cancelS
            .map({ PopupChallengeResult.cancel })
        
        let accept = acceptS
            .withLatestFrom(reasonS.startWith(""))
            .share()
            .map({ PopupChallengeResult.oke($0) })
        
        let actionSelected = Observable.merge(cancel, accept)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        output = Output(actionSelected: actionSelected)
    }
    
}
