//
//  SeeMoreViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

final class SeeMoreViewModel: ViewModelType {
    
    let input: Input
    let output: Output
    
    struct Input {
        let moreSelected: AnyObserver<SectionWordstadium>
    }
    
    struct Output {
        let moreSelected: Driver<SectionWordstadium>
    }
    
    private let moreSelectedSubject = PublishSubject<SectionWordstadium>()
    
    init() {
        input = Input(moreSelected: moreSelectedSubject.asObserver())
        output = Output(moreSelected: moreSelectedSubject.asDriverOnErrorJustComplete())
    }
}

