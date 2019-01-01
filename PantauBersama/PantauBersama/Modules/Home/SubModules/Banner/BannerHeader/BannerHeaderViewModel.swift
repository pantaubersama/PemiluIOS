//
//  BannerHeaderViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Networking

final class BannerHeaderViewModel: ViewModelType {
    
    let input: Input
    let output: Output
    
    struct Input {
        let itemSelected: AnyObserver<BannerInfo>
    }
    
    struct Output {
        let itemSelected: Driver<BannerInfo>
    }
    
    private let itemSelectedSubject = PublishSubject<BannerInfo>()
    
    init() {
        input = Input(itemSelected: itemSelectedSubject.asObserver())
        output = Output(itemSelected: itemSelectedSubject.asDriverOnErrorJustComplete())
    }
}
