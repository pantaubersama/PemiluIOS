//
//  BannerInfoViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class BannerInfoViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let finishTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let finish: Driver<Void>
        let bannerInfo: Driver<BannerInfo>
    }
    
    private let finishSubject = PublishSubject<Void>()
    
    init(bannerInfo: BannerInfo) {
        input = Input(finishTrigger: finishSubject.asObserver())
        
        let finish = finishSubject.asDriverOnErrorJustComplete()
        output = Output(finish: finish,
                        bannerInfo: Driver.just(bannerInfo))
    }
}
