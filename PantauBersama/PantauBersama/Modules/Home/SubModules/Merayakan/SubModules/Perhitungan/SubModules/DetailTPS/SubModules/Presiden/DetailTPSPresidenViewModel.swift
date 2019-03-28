//
//  HitungSuaraPresidenViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

class DetailTPSPresidenViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        
        let suara1I: PublishSubject<Int>
//        let suara2I: Observable<String?>
//        let suaraTidakSahI: Observable<String?>
    }
    
    struct Output {
        let backO: Driver<Void>
    }
    
    var input: Input
    var output: Output
    
    private let navigator: DetailTPSPresidenNavigator
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    
    private var request = BehaviorRelay(value: HitungPresidenRequest())
    private let bag = DisposeBag()
    
    init(navigator: DetailTPSPresidenNavigator) {
        self.navigator = navigator
        
        let suara1 = PublishSubject<Int>()
        input = Input(backI: backS.asObserver(), suara1I: suara1)
        
//        suara1.subscribe(onNext: { (suara) in
//            print("req changed \(suara)")
//        }).disposed(by: bag)
                
        request.map({ $0.suaraCalon1 }).bind(to: suara1).disposed(by: bag)
        
        request.subscribe(onNext: { (req) in
            print("req changed \(req)")
        }).disposed(by: bag)
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back)
    }
}

struct HitungPresidenRequest {
    var suaraCalon1: Int = 0
    var suaraCalon2: Int = 0
    var suaraTidakSah: Int = 0
}
