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
    case refuse
    case accept
    case `default`
}

class PopupChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let cancelI: AnyObserver<Void>
        let acceptI: AnyObserver<Void>
    }
    
    struct Output {
        let actionSelected: Driver<PopupChallengeResult>
    }
    
    private var navigator: PopupChallengeNavigator
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let cancelS = PublishSubject<Void>()
    private let acceptS = PublishSubject<Void>()
    
    init(navigator: PopupChallengeNavigator) {
        self.navigator = navigator
        
        input = Input(cancelI: cancelS.asObserver(),
                      acceptI: acceptS.asObserver())
        
        let cancel = cancelS
            .map({ PopupChallengeResult.cancel })
        
        let accept = acceptS
            .map({ PopupChallengeResult.oke("")})
        
        let actionSelected = Observable.merge(cancel, accept)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        output = Output(actionSelected: actionSelected)
    }
    
}
