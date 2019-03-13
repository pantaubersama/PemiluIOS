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

class DebatCommentViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let loadCommentI: AnyObserver<Void>
        let sendCommentI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let viewTypeO: Driver<DebatViewType>
        let loadCommentsO: Driver<Void>
        let commentsO: BehaviorRelay<[Word]>
        let sendCommentO: Driver<IndexPath>
    }
    
    var input: Input
    var output: Output!
    
    private let challenge: Challenge
    private let navigator: DebatCommentNavigator
    private let backS = PublishSubject<Void>()
    private let loadCommentS = PublishSubject<Void>()
    private let comments = BehaviorRelay<[Word]>(value: [])
    private let sendCommentS = PublishSubject<String>()
    
    init(navigator: DebatCommentNavigator, challenge: Challenge) {
        self.navigator = navigator
        self.challenge = challenge
        
        input = Input(
            backI: backS.asObserver(),
            loadCommentI: loadCommentS.asObserver(),
            sendCommentI: sendCommentS.asObserver()
        )
        
        let back = backS.flatMap({navigator.dismiss()})
            .asDriverOnErrorJustComplete()
        
        let viewType = Observable.just(getViewTypeFromChallenge())
            .asDriverOnErrorJustComplete()
        
        let loadComments = loadCommentS
            .flatMapLatest({ self.getComments() })
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
            .map({ _ in
                return IndexPath(row: self.comments.value.count - 1, section: 0)
            })
            .asDriverOnErrorJustComplete()
            
        output = Output(
            backO: back,
            viewTypeO: viewType,
            loadCommentsO: loadComments,
            commentsO: self.comments,
            sendCommentO: sendComment
        )
    }
    
    private func getComments() -> Observable<[Word]> {
        return NetworkService.instance.requestObject(WordstadiumAPI.wordsAudience(challengeId: self.challenge.id), c: BaseResponse<WordsResponse>.self)
            .map({ $0.data.words })
            .asObservable()
    }
    
    private func sendComment(word: String) -> Observable<Word> {
        return NetworkService.instance.requestObject(WordstadiumAPI.commentAudience(challengeId: self.challenge.id, words: word), c: BaseResponse<SendWordResponse>.self)
            .map({ $0.data.word })
            .asObservable()
    }
    
    private func getViewTypeFromChallenge() -> DebatViewType {
        let myEmail = AppState.local()?.user.email ?? ""
        let isParticipant = challenge.audiences.contains(where: { $0.email == myEmail })
        
        if isParticipant {
            return DebatViewType.participant
        } else {
            return DebatViewType.watch
        }
    }
}
