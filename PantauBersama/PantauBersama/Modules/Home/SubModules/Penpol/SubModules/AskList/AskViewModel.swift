//
//  AskViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa

class AskViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    struct Input {
        let createTrigger: AnyObserver<Void>
        let infoTrigger: AnyObserver<Void>
        let shareTrigger: AnyObserver<Any>
        let moreTrigger: AnyObserver<Any>
        let moreMenuTrigger: AnyObserver<AskType>
    }
    
    struct Output {
        let createSelected: Driver<Void>
        let infoSelected: Driver<Void>
        let shareSelected: Driver<Void>
        let moreSelected: Driver<Any>
        let moreMenuSelected: Driver<Void>
        
    }
    
    // TODO: replace any with Ask model
    private let createSubject = PublishSubject<Void>()
    private let infoSubject = PublishSubject<Void>()
    private let shareSubject = PublishSubject<Any>()
    private let moreSubject = PublishSubject<Any>()
    private let moreMenuSubject = PublishSubject<AskType>()
    
    private let navigator: QuizNavigator
    
    init(navigator: PenpolNavigator) {
        self.navigator = navigator
        
        input = Input(
            createTrigger: createSubject.asObserver(),
            infoTrigger: infoSubject.asObserver(),
            shareTrigger: shareSubject.asObserver(),
            moreTrigger: moreSubject.asObserver(),
            moreMenuTrigger: moreMenuSubject.asObserver())
        
        let create = createSubject
            .flatMapLatest({navigator.launchCreateAsk()})
            .asDriver(onErrorJustReturn: ())
        let info = infoSubject
            .flatMapLatest({navigator.openInfoPenpol(infoType: PenpolInfoType.Ask)})
            .asDriver(onErrorJustReturn: ())
        
        let moreAsk = moreSubject
            .asObserver().asDriverOnErrorJustComplete()
        
        let shareAsk = shareSubject
            .flatMapLatest({navigator.shareAsk(ask: $0)})
            .asDriver(onErrorJustReturn: ())
        
        let moreMenuSelected = moreMenuSubject
            .flatMapLatest({ (type) -> Observable<Void> in
                switch type {
                case .bagikan(let ask):
                    return navigator.shareAsk(ask: ask)
                default :
                    return Observable.empty()
                }
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            createSelected: create,
            infoSelected: info,
            shareSelected: shareAsk,
            moreSelected: moreAsk,
            moreMenuSelected: moreMenuSelected)
    }
    
    
}
