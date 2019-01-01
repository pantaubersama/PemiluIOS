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
        let bannerInfoCell: Driver<[ICellConfigurator]>
    }
    
    private let finishSubject = PublishSubject<Void>()
    init(bannerInfo: BannerInfo) {
        input = Input(finishTrigger: finishSubject.asObserver())
        
        let bannerInfoCells = [BannerInfoViewCellConfigurator(item: BannerInfoViewCell.Input(bannerInfo: bannerInfo))]
        
        let bannerCellDriver: Driver<[ICellConfigurator]> = Observable.just(bannerInfoCells).asDriverOnErrorJustComplete()
        
        let finish = finishSubject.asDriverOnErrorJustComplete()
        output = Output(finish: finish,
                        bannerInfoCell: bannerCellDriver)
    }
}
