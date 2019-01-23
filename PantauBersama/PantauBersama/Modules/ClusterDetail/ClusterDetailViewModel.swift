//
//  ClusterDetailViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Networking

class ClusterDetailViewModel: ViewModelType {
    struct Input {
        let backTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let back: Driver<Void>
        let cluster: Driver<ClusterDetail>
    }
    
    var input: Input
    var output: Output
    
    let backSubject = PublishSubject<Void>()
    
    init(cluster: ClusterDetail, navigator: ClusterDetailNavigator) {
        input = Input(backTrigger: backSubject.asObserver())
        
        let back = backSubject
            .flatMapLatest({ navigator.finish() })
            .asDriverOnErrorJustComplete()
        
        let clusterDetail = Observable.just(cluster).asDriverOnErrorJustComplete()
        
        output = Output(back: back, cluster: clusterDetail)
    }
}
