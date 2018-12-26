//
//  JanjiPolitikViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class JanjiPolitikViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let moreTrigger: AnyObserver<Any>
        let moreMenuTrigger: AnyObserver<JanjiType>
        let shareJanji: AnyObserver<Any>
    }
    
    struct Output {
        let moreSelected: Driver<Any>
        let moreMenuSelected: Driver<Void>
        let shareSelected: Driver<Void>
    }
    
    
    private let moreSubject = PublishSubject<Any>()
    private let moreMenuSubject = PublishSubject<JanjiType>()
    private let shareSubject = PublishSubject<Any>()
    
    private let navigator: JanjiPolitikNavigator
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        input = Input(moreTrigger: moreSubject.asObserver(),
                      moreMenuTrigger: moreMenuSubject.asObserver(),
                      shareJanji: shareSubject.asObserver())
        
        let more = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let shareJanji = shareSubject
            .flatMapLatest({ _ in navigator.shareJanji(data: "Any") })
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest { (type) -> Observable<Void> in
                switch type {
                case .bagikan:
                    return navigator.shareJanji(data: "as")
                case .salin:
                    return navigator.sharePilpres(data: "sa")
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
        output = Output(moreSelected: more,
                        moreMenuSelected: moreMenuSelected,
                        shareSelected: shareJanji)
    }
}
