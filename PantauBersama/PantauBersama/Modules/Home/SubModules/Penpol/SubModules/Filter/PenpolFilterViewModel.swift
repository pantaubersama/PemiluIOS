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
        let cidTrigger: BehaviorSubject<String>
    }
    
    struct Output {
        let filterItems: [PenpolFilterModel]
        let apply: Driver<Void>
        let cid: Driver<String>
    }
    
    private let filterItems: [PenpolFilterModel]
    private let filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>
    private let applySubject = PublishSubject<Void>()
    private let cidSubject = BehaviorSubject<String>(value: "")
    
    init(filterItems: [PenpolFilterModel], filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) {
        self.filterItems = filterItems
        self.filterTrigger = filterTrigger
        input = Input(filterTrigger: filterTrigger,
                      applyTrigger: applySubject.asObserver(),
                      cidTrigger: cidSubject.asObserver())
        
        let apply = applySubject
            .asDriverOnErrorJustComplete()
        
        output = Output(filterItems: self.filterItems, apply: apply, cid: cidSubject.asDriver(onErrorJustReturn: ""))
    }
}
