//
//  DebatCommentViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class DebatCommentViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let navigator: DebatCommentNavigator
    private let backS = PublishSubject<Void>()
    init(navigator: DebatCommentNavigator) {
        self.navigator = navigator
        
        input = Input(backTrigger: backS.asObserver())
        
        let back = backS.flatMap({navigator.dismiss()})
            .asDriverOnErrorJustComplete()
        
        output = Output(back: back)
    }
}
