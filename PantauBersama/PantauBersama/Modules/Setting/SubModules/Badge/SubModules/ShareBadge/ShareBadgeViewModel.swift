//
//  ShareBadgeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

final class ShareBadgeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        
    }
    
    private var navigator: ShareBadgeNavigator
    private let backS = PublishSubject<Void>()
    
    init(navigator: ShareBadgeNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver())
        
        output = Output()
        
    }
    
}
