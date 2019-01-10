//
//  WKWebViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 11/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class WKWebViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let urlO: Driver<String>
    }
    
    private var navigator: WKWebNavigator
    private let url: String
    private let backS = PublishSubject<Void>()
    
    init(navigator: WKWebNavigator, url: String) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.url = url
        
        input = Input(backI: backS.asObserver())
        
        output = Output(urlO: Driver.just(url).asDriver(onErrorJustReturn: ""))
        
    }
    
}
