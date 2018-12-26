//
//  UndangAnggotaViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class UndangAnggotaViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let undangTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let createSelected: Driver<Void>
    }
    
    private let undangSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    var navigator: UndangAnggotaNavigator
    
    init(navigator: UndangAnggotaNavigator) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        
        input = Input(backTrigger: backSubject.asObserver() ,undangTrigger: undangSubject.asObserver())
        
        let create = undangSubject
            .asDriver(onErrorJustReturn: ())
        
        output = Output(createSelected: create )
    }
    
}
