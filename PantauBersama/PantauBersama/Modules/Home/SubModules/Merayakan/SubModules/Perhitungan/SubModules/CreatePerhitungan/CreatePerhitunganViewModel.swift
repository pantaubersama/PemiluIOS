//
//  CreatePerhitunganViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class CreatePerhitunganViewModel: ViewModelType {
    struct Input {
        let detailTPSI: AnyObserver<Void>
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let detailTPSO: Driver<Void>
        let backO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let navigator: CreatePerhitunganNavigator
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    
    init(navigator: CreatePerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input(
            detailTPSI: detailTPSS.asObserver(),
            backI: backS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let detail = detailTPSS
            .flatMap({ navigator.launchDetailTPS() })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            detailTPSO: detail,
            backO: back)
    }
}
