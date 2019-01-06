//
//  KategoriClusterViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

class KategoriClusterViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        
    }
    
    private let backS = PublishSubject<Void>()
    private var navigator: KategoriClusterProtocol
    
    init(navigator: KategoriClusterProtocol) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver())
        
        output = Output()
        
    }
    
    
}
