//
//  HitungSuaraPresidenViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class DetailTPSPresidenViewModel: ViewModelType {
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
    
    private let navigator: DetailTPSPresidenNavigator
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    
    init(navigator: DetailTPSPresidenNavigator) {
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
