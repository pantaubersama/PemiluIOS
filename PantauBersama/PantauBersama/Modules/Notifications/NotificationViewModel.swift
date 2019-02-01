//
//  NotificationViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

final class NotificationViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
    }
    
    let navigator: NotificationNavigator
    private let backS = PublishSubject<Void>()
    
    init(navigator: NotificationNavigator) {
        self.navigator = navigator
        
        input = Input(backI: backS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back)
    }
}
