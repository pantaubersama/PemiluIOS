//
//  PenpolFilterViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class PenpolFilterViewModel: ViewModelType {
    var input: Input
    var output: Output!
    
    struct Input {
        let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
        let applyTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let filterItems: [PenpolFilterModel]
        let apply: Driver<Void>
    }
    
    private let filterItems: [PenpolFilterModel]
    private let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
    private let applySubject = PublishSubject<Void>()
    
    init(filterItems: [PenpolFilterModel], filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) {
        self.filterItems = filterItems
        self.filterTrigger = filterTrigger
        input = Input(filterTrigger: filterTrigger, applyTrigger: applySubject.asObserver())
        
        let apply = applySubject
            .asDriverOnErrorJustComplete()
        
        output = Output(filterItems: self.filterItems, apply: apply)
    }
}
