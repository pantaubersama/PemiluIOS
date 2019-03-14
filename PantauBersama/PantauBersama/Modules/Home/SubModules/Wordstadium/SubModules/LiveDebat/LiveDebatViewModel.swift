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
import FirebaseMessaging

class LiveDebatViewModel: ViewModelType {
    struct Input {
        let loadArgumentsI: AnyObserver<Void>
        let backI: AnyObserver<Void>
        let launchDetailI: AnyObserver<Void>
        let showCommentI: AnyObserver<Void>
        let viewTypeI: AnyObserver<(viewType: DebatViewType, challenge: Challenge)>
        let showMenuI: AnyObserver<Void>
        let selectMenuI: AnyObserver<String>
        let sendArgumentsI: AnyObserver<String>
        let sendCommentI: AnyObserver<String>
        let syncWordI: AnyObserver<Void>
        let latestCommentI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let launchDetailO: Driver<Void>
        let showCommentO: Driver<Void>
        let viewTypeO: Driver<(viewType: DebatViewType, challenge: Challenge)>
        let menuO: Driver<Void>
        let menuSelectedO: Driver<String>
        let challengeO: Driver<Challenge>
        let argumentsO: BehaviorRelay<[Word]>
        let loadArgumentsO: Driver<Void>
        let sendArgumentO: Driver<IndexPath>
        let sendCommentO: Driver<Void>
        let syncWordO: Driver<IndexPath>
        let latestCommentO: Driver<Word?>
        let newWordO: Driver<IndexPath>
        let timeLeftO: Driver<String>
    }
    
    var input: Input
    var output: Output!
    private let navigator: LiveDebatNavigator
    private let challenge: Challenge
    private let syncInterval: Double = 10.0
    
    private let backS = PublishSubject<Void>()
    private let detailS = PublishSubject<Void>()
    private let commentS = PublishSubject<Void>()
    private let viewTypeS = PublishSubject<(viewType: DebatViewType, challenge: Challenge)>()
    private let menuS = PublishSubject<Void>()
    private let selectMenuS = PublishSubject<String>()
    private let loadArgumentsS = PublishSubject<Void>()
    private let arguments = BehaviorRelay<[Word]>(value: [])
    private let loadArgumentS = PublishSubject<Void>()
    private let sendArgumentS = PublishSubject<String>()
    private let sendCommentS = PublishSubject<String>()
    private let latestCommentS = PublishSubject<Void>()
    private let syncWordS = PublishSubject<Void>()
    private let newWordS = PublishSubject<Word>()
    private let timeLeftS = PublishSubject<Double>()
    
    init(navigator: LiveDebatNavigator, challenge: Challenge) {
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
            sendArgumentsI: sendArgumentS.asObserver(),
            sendCommentI: sendCommentS.asObserver(),
            syncWordI: syncWordS.asObserver(),
            latestCommentI: latestCommentS.asObserver()
        )
        
        let back = backS
            .do(onNext: { (_) in
                /// Unsubcribe topic debat
                Messaging.messaging().unsubscribe(fromTopic: "ios-fighter-\(challenge.id)")
                Messaging.messaging().unsubscribe(fromTopic: "ios-audience-\(challenge.id)")
            })
            .flatMap({navigator.back()})
            .asDriverOnErrorJustComplete()
        
        let detail = detailS.flatMap({navigator.launchDetail()})
            .asDriverOnErrorJustComplete()
        
        let comment = commentS.flatMap({navigator.showComment()})
            .asDriverOnErrorJustComplete()
        
        let viewType = viewTypeS.startWith((viewType: getViewTypeFromChallenge(), challenge: challenge))
            .asDriverOnErrorJustComplete()
        
        
        let menu = menuS.asDriverOnErrorJustComplete()
        
        let selectMenu = selectMenuS.asDriverOnErrorJustComplete()
        
        // fallback mechanism, sync words every syncInterval
        // if latest remote word from sync is the same with latest local word, terminate the next action, but if different then insert that word and notify the ui
        let timer = Observable<Int>.timer(0, period: syncInterval, scheduler: MainScheduler.instance).mapToVoid()
        let syncWord = Observable.of(timer, syncWordS.asObservable())
            .merge()
            .flatMapLatest({ [unowned self] in self.getArguments() })
            .filter({ [weak self](words) -> Bool in
                guard let `self` = self else { return false }
                return self.isNewWordAdded(words: words) && self.arguments.value.last?.author.email != "wkwk@wkwkw.com"
            })
            .do(onNext: { [weak self](words) in
                guard let `self` = self else { return }
                self.arguments.accept(words)
                self.determineRoleFromLatestWord(words: words)
            })
            .map({ [weak self]_ in
                return IndexPath(row: (self?.arguments.value.count ?? 0) - 1, section: 0)
            })
            .asDriverOnErrorJustComplete()
        
        
        let loadArguments = loadArgumentS
            .flatMapLatest({ [unowned self] in self.getArguments() })
            .do(onNext: { [weak self](words) in
                guard let `self` = self else { return }
                self.arguments.accept(words)
                self.determineRoleFromLatestWord(words: words)
                
                let myWord = words.filter({ $0.isMyWord })
                self.timeLeftS.onNext(myWord.last?.timeLeft ?? 0)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let sendArgument = sendArgumentS
            .flatMapLatest({ [unowned self] in self.sendArgument(word: $0) })
            .do(onNext: { [weak self](word) in
                guard let `self` = self else { return }
                self.appendWord(word: word)
                self.timeLeftS.onNext(word.timeLeft ?? 0)
            })
            .map({ [weak self]_ in
                return IndexPath(row: (self?.arguments.value.count ?? 0) - 1, section: 0)
            })
            .asDriverOnErrorJustComplete()
        
        let sendComment = sendCommentS
            .flatMapLatest({ [unowned self] in self.sendComment(word: $0) })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let latestComment = latestCommentS
            .flatMapLatest({ [unowned self] in self.getComments() })
            .map({ $0.last })
            .asDriverOnErrorJustComplete()
        
        let newWord = newWordS
            .do(onNext: {[weak self](word) in
                guard let `self` = self else { return }
                self.appendWord(word: word)
            })
            .map({ [weak self]_ in
                return IndexPath(row: (self?.arguments.value.count ?? 0) - 1, section: 0)
            })
            .asDriverOnErrorJustComplete()
        
        let timeLeft = timeLeftS
            .map({ "\($0)"})
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
            sendArgumentO: sendArgument,
            sendCommentO: sendComment,
            syncWordO: syncWord,
            latestCommentO: latestComment,
            newWordO: newWord,
            timeLeftO: timeLeft)
    }
    
    private func determineRoleFromLatestWord(words: [Word]) {
        // if words is empty it means that debat just started, so the first turn is challenger, then we trigger the viewType
        if !challenge.isParticipant {
            self.viewTypeS.onNext((viewType: .watch, challenge: self.challenge))
            return
        }
        
        guard let lastWord = words.last else {
            let viewType = challenge.isMyChallenge ? DebatViewType.myTurn : DebatViewType.theirTurn
            self.viewTypeS.onNext((viewType: viewType, challenge: self.challenge))
            return
        }
        
        // if the last word/argument is my word then viewType is theirTurn
        self.viewTypeS.onNext((viewType: lastWord.isMyWord ? .theirTurn : .myTurn, challenge: self.challenge))
    }
    
    private func getArguments() -> Observable<[Word]> {
        return NetworkService.instance.requestObject(WordstadiumAPI.wordsFighter(challengeId: self.challenge.id), c: BaseResponse<WordsResponse>.self)
            .map({ $0.data.words })
            .asObservable()
    }
    
    private func getComments() -> Observable<[Word]> {
        return NetworkService.instance.requestObject(WordstadiumAPI.wordsAudience(challengeId: self.challenge.id), c: BaseResponse<WordsResponse>.self)
            .map({ $0.data.words })
            .asObservable()
    }
    
    private func sendArgument(word: String) -> Observable<Word> {
        return NetworkService.instance.requestObject(WordstadiumAPI.fighterAttack(challengeId: self.challenge.id, words: word), c: BaseResponse<SendWordResponse>.self)
            .map({ $0.data.word })
            .asObservable()
    }
    
    private func sendComment(word: String) -> Observable<Word> {
        return NetworkService.instance.requestObject(WordstadiumAPI.commentAudience(challengeId: self.challenge.id, words: word), c: BaseResponse<SendWordResponse>.self)
            .map({ $0.data.word })
            .asObservable()
    }
    
    private func getViewTypeFromChallenge() -> DebatViewType {
        NotificationCenter.default.addObserver(self, selector: #selector(self.incomingWord(_:)), name: NSNotification.Name(rawValue: "incoming-word"), object: nil)
        if  self.challenge.isParticipant {
            /// Register subscribe notifications for Fighters and Audiences
            /// Because we need data new argument and new comment
            Messaging.messaging().subscribe(toTopic: "ios-fighter-\(challenge.id)")
            Messaging.messaging().subscribe(toTopic: "ios-audience-\(challenge.id)")
            return DebatViewType.participant
        } else {
            // subscribe notifications from Fighters
            Messaging.messaging().subscribe(toTopic: "ios-fighter-\(challenge.id)")
            return DebatViewType.watch
        }
    }
    
    private func isNewWordAdded(words: [Word]) -> Bool {
        guard let currentLastWord = self.arguments.value.last else { return false }
        guard let lastRemoteWord = words.last else { return false }
        return currentLastWord.id != lastRemoteWord.id && words.count != self.arguments.value.count
    }
    
    private func appendWord(word: Word) {
        var latestValue = self.arguments.value
        latestValue.append(word)
        self.arguments.accept(latestValue)
        self.viewTypeS.onNext((viewType: word.isMyWord ? .theirTurn : .myTurn, challenge: self.challenge))
    }
    
    @objc func incomingWord(_ notification: NSNotification) {
        guard let word = notification.userInfo?["word"] as? Word else { return }
        if self.isNewWordAdded(words: [word]) {
            self.newWordS.onNext(word)
        }
    }
}

extension Word {
    public var isMyWord: Bool {
        let myEmail = AppState.local()?.user.email ?? ""
        return self.author.email == myEmail
    }
}

extension Challenge {
    public var challenger: Audiences? {
        return self.audiences.filter({ $0.role == .challenger }).first
    }
    
    public var opponents: [Audiences] {
        return self.audiences.filter({ $0.role != .challenger })
    }
    
    public var enemyName: String {
        let myEmail = AppState.local()?.user.email ?? ""
        return self.audiences.filter({ $0.email != myEmail}).first?.fullName ?? ""
    }
    
    public var isParticipant: Bool {
        let myEmail = AppState.local()?.user.email ?? ""
        return self.audiences.contains(where: { $0.email == myEmail })
    }
    
    public var isMyChallenge: Bool {
        let myEmail = AppState.local()?.user.email ?? ""
        let challengerEmail = self.challenger?.email ?? ""
        return myEmail == challengerEmail
    }
    
    public var isAudience: Bool {
        let myEmail = AppState.local()?.user.email ?? ""
        return self.opponents.contains(where: { ($0.email ?? "") == myEmail })
    }
}
