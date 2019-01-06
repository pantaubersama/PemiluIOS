//
//  ClusterCellViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ClusterCellViewModel: ViewModelType {
    
    let input: Input
    let output: Output
    
    struct Input {
        let reqClusterTrigger: AnyObserver<Void>
        let itemSelected: AnyObserver<Int>
    }
    
    struct Output {
        let reqClusterSelected: Driver<Void>
        let itemSelected: Driver<Int>
    }
    
    var reqClusterSubject = PublishSubject<Void>()
    var itemSelectedSubject = PublishSubject<Int>()
    
    init() {
        input = Input(reqClusterTrigger: reqClusterSubject.asObserver(),
                      itemSelected: itemSelectedSubject.asObserver())
        
        output = Output(reqClusterSelected: reqClusterSubject.asDriverOnErrorJustComplete(),
                        itemSelected: itemSelectedSubject.asDriverOnErrorJustComplete())
    }
    
}
