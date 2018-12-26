//
//  PilpresViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class PilpresViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let moreTrigger: AnyObserver<Any>
        let moreMenuTrigger: AnyObserver<PilpresType>
        let sharePilpres: AnyObserver<Any>
    }
    
    struct Output {
        let moreSelected: Driver<Any>
        let moreMenuSelected: Driver<Void>
        let shareSelected: Driver<Void>
    }
    
    
    private let moreSubject = PublishSubject<Any>()
    private let moreMenuSubject = PublishSubject<PilpresType>()
    private let shareSubject = PublishSubject<Any>()
    
    private let navigator: PilpresNavigator
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        
        input = Input(
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver(),
            sharePilpres: shareSubject.asObserver())
        
        let more = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let sharePilpres = shareSubject
            .flatMapLatest({ navigator.sharePilpres(data: $0) })
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest({ (type) -> Observable<Void> in
                switch type {
                case .salin:
                    return navigator.sharePilpres(data: "data")
                case .bagikan:
                    return navigator.sharePilpres(data: "bagi")
                case .twitter:
                    return navigator.openTwitter(data: "www.twitter.com")
                }
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(moreSelected: more,
                        moreMenuSelected: moreMenuSelected,
                        shareSelected: sharePilpres)
        
    }
    
}
