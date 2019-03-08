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
        let loadArgumentsI: AnyObserver<Void>
        let backI: AnyObserver<Void>
        let launchDetailI: AnyObserver<Void>
        let showCommentI: AnyObserver<Void>
        let viewTypeI: AnyObserver<DebatViewType>
        let showMenuI: AnyObserver<Void>
        let selectMenuI: AnyObserver<String>
        let sendArgumentsI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let launchDetailO: Driver<Void>
        let showCommentO: Driver<Void>
        let viewTypeO: Driver<DebatViewType>
        let menuO: Driver<Void>
        let menuSelectedO: Driver<String>
        let challengeO: Driver<Challenge>
        let argumentsO: BehaviorRelay<[Word]>
        let loadArgumentsO: Driver<Void>
        let sendArgumentO: Driver<IndexPath>
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
    private let sendArgumentS = PublishSubject<String>()
    
    init(navigator: LiveDebatNavigator, challenge: Challenge, viewType: DebatViewType) {
        self.navigator = navigator
        self.challenge = challenge
        
        input = Input(
            loadArgumentsI: loadArgumentS.asObserver(),
            backI: backS.asObserver(),
            launchDetailI: detailS.asObserver(),
            showCommentI: commentS.asObserver(),
            viewTypeI: viewTypeS.asObserver(),
            showMenuI: menuS.asObserver(),
            selectMenuI: selectMenuS.asObserver(),
            sendArgumentsI: sendArgumentS.asObserver()
        )
        
        let back = backS.flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        let detail = detailS.flatMap({navigator.launchDetail()})
            .asDriverOnErrorJustComplete()
        
        let comment = commentS.flatMap({navigator.showComment()})
            .asDriverOnErrorJustComplete()
        
        let viewType = viewTypeS.startWith(getViewTypeFromChallenge())
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
        
        let sendArgument = sendArgumentS
            .flatMapLatest({ self.sendArgument(word: $0) })
            .do(onNext: { [weak self](word) in
                guard let `self` = self else { return }
                var latestValue = self.arguments.value
                latestValue.append(word)
                self.arguments.accept(latestValue)
            })
            .map({ _ in
                return IndexPath(row: self.arguments.value.count - 1, section: 0)
            })
            .asDriverOnErrorJustComplete()
            
        output = Output(
            backO: back,
            launchDetailO: detail,
            showCommentO: comment,
            viewTypeO: viewType,
            menuO: menu,
            menuSelectedO: selectMenu,
            challengeO: Driver.just(self.challenge),
            argumentsO: self.arguments,
            loadArgumentsO: loadArguments,
            sendArgumentO: sendArgument)
    }
    
    private func getArguments() -> Observable<[Word]> {
        return NetworkService.instance.requestObject(WordstadiumAPI.wordsFighter(challengeId: self.challenge.id), c: BaseResponse<WordsResponse>.self)
            .map({ $0.data.words })
            .asObservable()
    }
    
    private func sendArgument(word: String) -> Observable<Word> {
        return NetworkService.instance.requestObject(WordstadiumAPI.fighterAttack(challengeId: self.challenge.id, words: word), c: BaseResponse<SendWordResponse>.self)
            .map({ $0.data.word })
            .asObservable()
    }
    
    private func getViewTypeFromChallenge() -> DebatViewType {
        let myEmail = AppState.local()?.user.email ?? ""
        let isParticipant = challenge.audiences.contains(where: { $0.email == myEmail })
        
        if  isParticipant {
            return DebatViewType.participant
        } else {
            return DebatViewType.watch
        }
    }
}
