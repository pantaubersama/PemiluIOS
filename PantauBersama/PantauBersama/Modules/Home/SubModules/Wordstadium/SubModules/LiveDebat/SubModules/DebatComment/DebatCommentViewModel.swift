//
//  DebatCommentViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking
import FirebaseMessaging

class DebatCommentViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let loadCommentI: AnyObserver<Void>
        let sendCommentI: AnyObserver<String>
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let viewTypeO: Driver<DebatViewType>
        let loadCommentsO: Driver<Void>
        let commentsO: Driver<[Word]>
        let sendCommentO: Driver<Word>
        let newCommentO: Driver<Word>
    }
    
    var input: Input
    var output: Output!
    
    private let challenge: Challenge
    private let navigator: DebatCommentNavigator
    private let backS = PublishSubject<Void>()
    private let loadCommentS = PublishSubject<Void>()
    private let comments = BehaviorRelay<[Word]>(value: [])
    private let sendCommentS = PublishSubject<String>()
    private let nextSubject = PublishSubject<Void>()
    private let newCommentS = PublishSubject<Word>()
    
    init(navigator: DebatCommentNavigator, challenge: Challenge) {
        self.navigator = navigator
        self.challenge = challenge
        
        input = Input(
            backI: backS.asObserver(),
            loadCommentI: loadCommentS.asObserver(),
            sendCommentI: sendCommentS.asObserver(),
            nextI: nextSubject.asObserver()
        )
        
        let back = backS
            .do(onNext: { (_) in
                /// Unsubcribe audience because after comment release
                /// will present live debat
                Messaging.messaging().unsubscribe(fromTopic: "ios-audience-\(challenge.id)")
            })
            .flatMap({navigator.dismiss()})
            .asDriverOnErrorJustComplete()
        
        let viewType = Observable.just(getViewTypeFromChallenge())
            .asDriverOnErrorJustComplete()
        
        let loadComments = loadCommentS
            .flatMapLatest({ self.getComments() })
            .map({ (word) -> [Word] in
                return word.reversed()
            })
            .do(onNext: { [weak self](words) in
                guard let `self` = self else { return }
                self.comments.accept(words)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let sendComment = sendCommentS
            .flatMapLatest({ self.sendComment(word: $0) })
            .do(onNext: { [weak self](word) in
                guard let `self` = self else { return }
                var latestValue = self.comments.value
                latestValue.append(word)
                self.comments.accept(latestValue)
            })
            .asDriverOnErrorJustComplete()
        
        let newComment = newCommentS
            .do(onNext: { [weak self] (word) in
                guard let `self` = self else { return }
                var latestValue = self.comments.value
                latestValue.append(word)
                self.comments.accept(latestValue)
            })
            .asDriverOnErrorJustComplete()
            
        output = Output(
            backO: back,
            viewTypeO: viewType,
            loadCommentsO: loadComments,
            commentsO: self.comments.asDriverOnErrorJustComplete(),
            sendCommentO: sendComment,
            newCommentO: newComment
        )
    }
    
    private func getComments() -> Observable<[Word]> {
        return self.paginateItems(nextBatchTrigger: self.nextSubject.asObservable())
    }
    
    private func sendComment(word: String) -> Observable<Word> {
        return NetworkService.instance.requestObject(WordstadiumAPI.commentAudience(challengeId: self.challenge.id, words: word), c: BaseResponse<SendWordResponse>.self)
            .map({ $0.data.word })
            .asObservable()
    }
    
    private func getViewTypeFromChallenge() -> DebatViewType {
        let myEmail = AppState.local()?.user.email ?? ""
        let isParticipant = challenge.audiences.contains(where: { $0.email == myEmail })
        /// Register subscribe notification just for Audiences and Listen notifications value
        NotificationCenter.default.addObserver(self, selector: #selector(self.incomingWord(_:)), name: NSNotification.Name(rawValue: "incoming-word"), object: nil)
        Messaging.messaging().subscribe(toTopic: "ios-audience-\(challenge.id)")
        if isParticipant {
            return DebatViewType.participant
        } else {
            return DebatViewType.watch
        }
    }
    
    @objc func incomingWord(_ notification: NSNotification) {
        guard let word = notification.userInfo?["word"] as? Word else { return }
        if self.isNewWordAdded(words: [word]) == true {
            self.newCommentS.onNext(word)
        } else {
            print("word sudah ada")
        }
    }
    
    private func isNewWordAdded(words: [Word]) -> Bool {
        guard let currentLastWord = self.comments.value.last else { return false }
        guard let lastRemoteWord = words.last else { return false }
        return currentLastWord.id != lastRemoteWord.id
    }
    
    /**
     Configure Paginate items comment
     - Parameters:
     - Batch page and NextBatch page triggered from nextSubject
     - Returns: Observable<[Word]>
     **/
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>) -> Observable<[Word]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger)
            .scan([], accumulator: { (accumulator, page) in
                /// MARK: This is will throw error because currently pagination from BE not match
                let page = accumulator + page.item
                return page
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>) -> Observable<Page<[Word]>> {
        return NetworkService.instance
            .requestObject(WordstadiumAPI.wordsAudience(challengeId: challenge.id, page: batch.page, perPage: batch.limit), c: BaseResponse<WordsResponse>.self)
            .map({ self.transformToPage(response: $0, batch: batch )})
            .asObservable()
            .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                return result.batch.next().hasNextPage
            }, nextPageFactory: { (result) -> Observable<Page<[Word]>> in
                self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger)
            })
            .share(replay: 1, scope: .whileConnected)
        
    }
    
    private func transformToPage(response: BaseResponse<WordsResponse>, batch: Batch) -> Page<[Word]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[Word]>(
            item: response.data.words.reversed(),
            batch: nextBatch
        )
    }
}
