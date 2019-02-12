//
//  BidangKajianViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa


enum BidangKajianResult {
    case cancel
    case ok(id: String)
}


final class BidangKajianViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let cancelI: AnyObserver<UITapGestureRecognizer>
        let itemSelectedI: AnyObserver<IndexPath>
        let queryI: AnyObserver<String>
    }
    
    struct Output {
//        let itemsO: Driver<[String]>
        let actionSelected: Driver<BidangKajianResult>
    }
    
    private var navigator: BidangKajianNavigator
    private let cancelS = PublishSubject<UITapGestureRecognizer>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let queryS = PublishSubject<String>()
    
    init(navigator: BidangKajianNavigator) {
        self.navigator = navigator
        
        
        input = Input(cancelI: cancelS.asObserver(), itemSelectedI: itemSelectedS.asObserver(),
                      queryI: queryS.asObserver())
        
        let query = queryS
            .startWith("")
        
        
        let action = cancelS
            .map({ _ in BidangKajianResult.cancel })
        
        output = Output(actionSelected: action.asDriverOnErrorJustComplete())
    }
    
}
