//
//  AboutViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 16/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

final class AboutViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let licenseI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let licenseO: Driver<Void>
    }
    
    private var navigator: AboutNavigator
    private let backS = PublishSubject<Void>()
    private let licenseS = PublishSubject<Void>()
    
    init(navigator: AboutNavigator) {
        self.navigator = navigator
        
        
        input = Input(backI: backS.asObserver(), licenseI: licenseS.asObserver())
        
        let back = backS
            .do(onNext: { (_) in
                navigator.back()
            })
            .asDriverOnErrorJustComplete()
        
        let license = licenseS
            .flatMapLatest({ navigator.linsensi(link: AppContext.instance.infoForKey("LicenseURL"))})
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back, licenseO: license)
        
    }
    
}
