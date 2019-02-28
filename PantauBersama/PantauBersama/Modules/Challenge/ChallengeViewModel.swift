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
    }
    
    struct Output {
        let backO: Driver<Void>
        let actionO: Driver<Void>
        let challengeO: Driver<Challenge>
    }
    
    private var navigator: ChallengeNavigator
    private var data: Challenge
    
    private let backS = PublishSubject<Void>()
    private let actionButtonS = PublishSubject<Void>()
    private let challengeS = PublishSubject<Challenge>()
    
    init(navigator: ChallengeNavigator, data: Challenge) {
        self.navigator = navigator
        self.data = data
        
        input = Input(
            backI: backS.asObserver(),
            actionButtonI: actionButtonS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let action = actionButtonS
            .flatMapLatest { [unowned self](_) -> Observable<PopupChallengeResult> in
                // openChallenge without opponent candidate will open dialog confirmation
                if self.data.progress == .waitingOpponent && self.data.type == .openChallenge {
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
        
        output = Output(backO: back, actionO: action, challengeO: challenge)
    }
    
    private func putAskAsOpponent(into id: String) -> Observable<Bool> {
        return NetworkService.instance.requestObject(WordstadiumAPI.askAsOpponent(id: id), c: PutAskAsOpponentResponse.self)
            .map({ (response) -> Bool in
                return response.data.message == "Berhasil mencalonkan diri sebagai Lawan!"
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
        // result selection
        switch popupResult {
        case .oke: // when positive button tap
            
            // when user tap positive button and the challenge is open challenge,
            // it means that user want to be the opponent candidate
            if data.type == .openChallenge {
                return putAskAsOpponent(into: data.id)
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
