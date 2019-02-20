//
//  WordstadiumCellViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 17/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

final class WordstadiumCellViewModel: ViewModelType {
    
    let input: Input
    let output: Output
    
    struct Input {
        let moreSelected: AnyObserver<SectionWordstadium>
        let itemSelected: AnyObserver<Wordstadium>
    }
    
    struct Output {
        let moreSelected: Driver<SectionWordstadium>
        let itemSelected: Driver<Wordstadium>
    }
    
    private let moreSelectedSubject = PublishSubject<SectionWordstadium>()
    private let itemSelectedSubject = PublishSubject<Wordstadium>()
    
    init() {
        input = Input(moreSelected: moreSelectedSubject.asObserver(),
                      itemSelected: itemSelectedSubject.asObserver())
        
        output = Output(moreSelected: moreSelectedSubject.asDriverOnErrorJustComplete(),
                        itemSelected: itemSelectedSubject.asDriverOnErrorJustComplete())
    }
}
