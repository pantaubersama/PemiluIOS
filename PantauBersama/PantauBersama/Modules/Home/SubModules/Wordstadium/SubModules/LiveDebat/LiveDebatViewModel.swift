//
//  LiveDebatViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class LiveDebatViewModel: ViewModelType {
    struct Input {
        let loadArgumentsTrigger: AnyObserver<Void>
        let backTrigger: AnyObserver<Void>
        let launchDetailTrigger: AnyObserver<Void>
        let showCommentTrigger: AnyObserver<Void>
        let viewTypeTrigger: AnyObserver<DebatViewType>
        let showMenuTrigger: AnyObserver<Void>
        let selectMenuTrigger: AnyObserver<String>
    }
    
    struct Output {
        let back: Driver<Void>
        let launchDetail: Driver<Void>
        let showComment: Driver<Void>
        let viewType: Driver<DebatViewType>
        let menu: Driver<Void>
        let menuSelected: Driver<String>
        let challenge: Driver<Challenge>
        let arguments: BehaviorRelay<[Word]>
        let loadArguments: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    private let navigator: LiveDebatNavigator
    private let challenge: Challenge
    
    private let backS = PublishSubject<Void>()
    private let detailS = PublishSubject<Void>()
    private let commentS = PublishSubject<Void>()
    private let viewTypeS = PublishSubject<DebatViewType>()
    private let menuS = PublishSubject<Void>()
    private let selectMenuS = PublishSubject<String>()
    private let loadArgumentsS = PublishSubject<Void>()
    private let arguments = BehaviorRelay<[Word]>(value: [])
    private let loadArgumentS = PublishSubject<Void>()
    
    init(navigator: LiveDebatNavigator, challenge: Challenge, viewType: DebatViewType) {
        self.navigator = navigator
        self.challenge = challenge
        
        input = Input(
            loadArgumentsTrigger: loadArgumentS.asObserver(),
            backTrigger: backS.asObserver(),
            launchDetailTrigger: detailS.asObserver(),
            showCommentTrigger: commentS.asObserver(),
            viewTypeTrigger: viewTypeS.asObserver(),
            showMenuTrigger: menuS.asObserver(),
            selectMenuTrigger: selectMenuS.asObserver()
        )
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        let detail = detailS.flatMap({navigator.launchDetail()})
            .asDriverOnErrorJustComplete()
        
        let comment = commentS.flatMap({navigator.showComment()})
            .asDriverOnErrorJustComplete()
        
        let viewType = viewTypeS.startWith(viewType)
            .asDriverOnErrorJustComplete()
        
        
        let menu = menuS.asDriverOnErrorJustComplete()
        
        let selectMenu = selectMenuS.asDriverOnErrorJustComplete()
        
        let loadArguments = loadArgumentS
            .flatMap({ self.getArguments() })
            .do(onNext: { [weak self](words) in
                guard let `self` = self else { return }
                self.arguments.accept(words)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
            
        output = Output(
            back: back,
            launchDetail: detail,
            showComment: comment,
            viewType: viewType,
            menu: menu,
            menuSelected: selectMenu,
            challenge: Driver.just(self.challenge),
            arguments: self.arguments,
            loadArguments: loadArguments)
    }
    
    private func getArguments() -> Observable<[Word]> {
        return NetworkService.instance.requestObject(WordstadiumAPI.wordsFighter(challengeId: self.challenge.id), c: BaseResponse<WordsResponse>.self)
            .map({ $0.data.words })
            .asObservable()
    }
}
