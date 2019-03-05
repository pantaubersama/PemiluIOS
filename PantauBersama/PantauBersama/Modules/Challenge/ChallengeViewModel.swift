//
//  ChallengeViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

enum ChallengeType {
    case soon
    case done
    case challenge
    case `default`
    case challengeOpen
    case challengeDirect
    case challengeDenied
    case challengeExpired
}

class ChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    
    struct Input {
        let backI: AnyObserver<Void>
        let actionButtonI: AnyObserver<Void>
        let confirmOpponentI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let actionO: Driver<Void>
        let challengeO: Driver<Challenge>
        let audienceO: Driver<[Audiences]>
        let confirmOpponentO: Driver<Void>
    }
    
    private var navigator: ChallengeNavigator
    private var data: Challenge
    
    private let backS = PublishSubject<Void>()
    private let actionButtonS = PublishSubject<Void>()
    private let challengeS = PublishSubject<Challenge>()
    private let confirmOpponentS = PublishSubject<String>()
    
    private var selectedAudience = ""
    
    init(navigator: ChallengeNavigator, data: Challenge) {
        self.navigator = navigator
        self.data = data
        
        input = Input(
            backI: backS.asObserver(),
            actionButtonI: actionButtonS.asObserver(),
            confirmOpponentI: confirmOpponentS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let action = actionButtonS
            .flatMapLatest { [unowned self](_) -> Observable<PopupChallengeResult> in
                // openChallenge before challenger confirm the opponent, accept button still visible
                if (self.data.progress == .waitingOpponent || self.data.progress == .waitingConfirmation) && self.data.type == .openChallenge {
                    return navigator.openAcceptConfirmation()
                }
                return Observable.empty()
            }
            .flatMap({ [weak self](popupResult) -> Observable<Bool> in
                guard let `self` = self else { return Observable.empty() }
                return self.handlePopupResult(popupResult: popupResult)
            })
            .filter({ $0 })
            .flatMap({ _ in self.getChallengeDetail(id: data.id)})
            .do(onNext: { [weak self](challenge) in
                guard let `self` = self else { return }
                self.challengeS.onNext(challenge)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let challenge = challengeS.startWith(data)
            .asDriverOnErrorJustComplete()
        
        let audience = challengeS.startWith(data)
            .map { (challenge) -> [Audiences] in
                return challenge.audiences.filter({ $0.role != AudienceRole.challenger })
            }
            .asDriverOnErrorJustComplete()
        
        let confirmOpponent = confirmOpponentS
            .flatMapLatest { [unowned self](audienceId) -> Observable<PopupChallengeResult> in
                self.selectedAudience = audienceId
                return navigator.openAcceptConfirmation()
            }
            .flatMap({ [weak self](popupResult) -> Observable<Bool> in
                guard let `self` = self else { return Observable.empty() }
                return self.handlePopupResult(popupResult: popupResult)
            })
            .filter({ $0 })
            .flatMap({ _ in self.getChallengeDetail(id: data.id) })
            .do(onNext: { [weak self](challenge) in
                guard let `self` = self else { return }
                self.challengeS.onNext(challenge)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        output = Output(backO: back,
                        actionO: action,
                        challengeO: challenge,
                        audienceO: audience,
                        confirmOpponentO: confirmOpponent)
    }
    
    private func putAskAsOpponent(into id: String) -> Observable<Bool> {
        return NetworkService.instance.requestObject(WordstadiumAPI.askAsOpponent(id: id), c: PutAskAsOpponentResponse.self)
            .map({ (response) -> Bool in
                return response.data.message == "Berhasil mencalonkan diri sebagai Lawan!"
            })
            .asObservable()
    }
    
    private func putConfirmAudience(id: String) -> Observable<Bool> {
        return NetworkService.instance.requestObject(WordstadiumAPI.confirmCandidateAsOpponent(challengeId: self.data.id, audienceId: id), c: PutAskAsOpponentResponse.self)
            .map({ (response) -> Bool in
                return response.data.message == "Berhasil memilih Lawan!"
            })
            .asObservable()
        
    }
    
    private func getChallengeDetail(id: String) -> Observable<Challenge> {
        return NetworkService.instance.requestObject(WordstadiumAPI.getChallengeDetail(id: id), c: BaseResponse<GetChallengeDetailResponse>.self)
            .map({ (response) -> Challenge in
                return response.data.challenge
            })
            .asObservable()
    }
    
    private func handlePopupResult(popupResult: PopupChallengeResult) -> Observable<Bool> {
        let myEmail = AppState.local()?.user.email ?? ""
        let challenger = data.audiences.filter({ $0.role == .challenger }).first
        let isMyChallenge = myEmail == (challenger?.email ?? "")
        // result selection
        switch popupResult {
        case .oke: // when positive button tap
            
            // when user tap positive button and the challenge is open challenge with waiting opponent status or waiting confirmation status and its not my challenge,
            // it means that user want to be the opponent candidate
            if data.type == .openChallenge && (data.progress == .waitingOpponent || data.progress == .waitingConfirmation) && !isMyChallenge {
                return putAskAsOpponent(into: data.id)
            }
            
            // when user tap positive button to confirm the audience as opponent
            if data.type == .openChallenge && data.progress == .waitingConfirmation && isMyChallenge {
                return putConfirmAudience(id: self.selectedAudience)
            }
            
            // other condition please add below
            //                    if weakSelf.data.type == .directChallenge {
            //
            //                    }
            
            return Observable.just(false)
        case .cancel: //when dismiss/negative button tap just return false to dismiss and do nothing
            return Observable.just(false)
        }
    }
    
}
