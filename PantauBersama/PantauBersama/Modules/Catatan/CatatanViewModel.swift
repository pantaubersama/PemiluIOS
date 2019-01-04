//
//  CatatanViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking


class CatatanViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        
    }
    
    private var navigator: CatatanNavigator
    private let backS = PublishSubject<Void>()
    
    init(navigator: CatatanNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        
        input = Input(
            backI: backS.asObserver()
        )
        
        output = Output()
    }
    
}
