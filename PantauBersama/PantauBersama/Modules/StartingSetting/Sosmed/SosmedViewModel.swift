//
//  SosmedViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking


final class SosmedViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
    }
    
    struct Output {
        let itemsO: Driver<[SectionOfSettingData]>
        let doneO: Driver<Void>
//        let itemsSelectedO: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private var navigator: SosmedNavigator
    
    init(navigator: SosmedNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(
            backI: backS.asObserver(),
            doneI: doneS.asObserver()
        )
        
        let items = Driver.just([
            SectionOfSettingData(header: "Twitter", items: [
                SettingData.twitter
                ]),
            SectionOfSettingData(header: "Facebook", items: [
                SettingData.facebook
                ])
            ])
        
        let done = doneS
            .flatMapLatest({ navigator.launchHome() })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            itemsO: items,
            doneO: done
        )
        
    }
    
}
