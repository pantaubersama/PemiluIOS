//
//  PerhitunganViewModel.swift
//  PantauBersama
//
//  Created by asharijuang on 20/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class PerhitunganViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let loadDataTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let items: Driver<[String]>
    }
    
    private let loadDataSubject     = PublishSubject<Void>()
    let navigator: PerhitunganNavigator
    
    init(navigator: PerhitunganNavigator) {
        self.navigator = navigator
        
        
        input = Input(
            loadDataTrigger: loadDataSubject.asObserver()
        )
        
        let items = loadDataSubject
            .do(onNext: { (_) in
                print("clicked")
            })
            .map { (_) -> [String] in
                return ["TPS1","TPS2","TPS3","TPS4"]
            }
            .asDriver(onErrorJustReturn: [])

        
    }
}
