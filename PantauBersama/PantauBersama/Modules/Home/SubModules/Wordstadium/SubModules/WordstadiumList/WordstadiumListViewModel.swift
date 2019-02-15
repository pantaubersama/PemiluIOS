//
//  WordstadiumListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class WordstadiumListViewModel: ViewModelType {
    var input: Input!
    var output: Output!
    
    struct Input {
        let backTriggger: AnyObserver<Void>
    }
    
    struct Output {
    }
    
    
    private var navigator: WordstadiumListNavigator
    private let backSubject = PublishSubject<Void>()
    
    init(navigator: WordstadiumListNavigator) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(backTriggger: backSubject.asObserver())
    }
}
