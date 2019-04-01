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

enum ChallengeDetailResult {
    case result(id: String)
    case cancel
}

class ChallengeViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    
    struct Input {
        let backI: AnyObserver<Void>
        let actionButtonI: AnyObserver<Void>
        let confirmOpponentI: AnyObserver<String>
        let refuseII: AnyObserver<Void>
        let shareI: AnyObserver<Void>
        let moreI: AnyObserver<Challenge>
        let moreMenuI: AnyObserver<ChallengeDetailType>
        let loveI: AnyObserver<Void>
        let deleteI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<ChallengeDetailResult>
        let actionO: Driver<Void>
        let challengeO: Driver<Challenge>
        let audienceO: Driver<[Audiences]>
        let confirmOpponentO: Driver<Void>
        let refuseO: Driver<Void>
        let shareO: Driver<Void>
        let moreO: Driver<Challenge>
        let moreMenuO: Driver<String>
        let loveO: Driver<Void>
    }
    
    private var navigator: ChallengeNavigator
    private var data: Challenge
    
    private let backS = PublishSubject<Void>()
    private let actionButtonS = PublishSubject<Void>()
    private let challengeS = PublishSubject<Challenge>()
    private let confirmOpponentS = PublishSubject<String>()
    private let refuseS = PublishSubject<Void>()
    private let shareS = PublishSubject<Void>()
    private let moreS = PublishSubject<Challenge>()
    private let moreMenuS = PublishSubject<ChallengeDetailType>()
    private let loveS = PublishSubject<Void>()
    private let deleteS = PublishSubject<String>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private var selectedAudience = ""
    
    init(navigator: ChallengeNavigator, data: Challenge) {
        self.navigator = navigator
        self.data = data
        
        input = Input(
            backI: backS.asObserver(),
            actionButtonI: actionButtonS.asObserver(),
            confirmOpponentI: confirmOpponentS.asObserver(),
            refuseII: refuseS.asObserver(),
            shareI: shareS.asObserver(),
            moreI: moreS.asObserver(),
            moreMenuI: moreMenuS.asObserver(),
            loveI: loveS.asObserver(),
            deleteI: deleteS.asObserver())
        
//        let back = backS
//            .flatMapLatest({ navigator.back() })
//            .asDriverOnErrorJustComplete()
        
        let action = actionButtonS
            .flatMapLatest { [unowned self](_) -> Observable<PopupChallengeResult> in
                // openChallenge before challenger confirm the opponent, accept button still visible
                if (self.data.progress == .waitingOpponent || self.data.progress == .waitingConfirmation) && self.data.type == .openChallenge {
                    return navigator.openAcceptConfirmation(type: .acceptOpen)
                } else if (self.data.progress == .waitingOpponent || self.data.progress == .waitingConfirmation) && self.data.type == .directChallenge {
                    return navigator.openAcceptConfirmation(type: .acceptDirect)
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
        
        /// Confirm Opponent from my challenge
        let confirmOpponent = confirmOpponentS
            .flatMapLatest { [unowned self](audienceId) -> Observable<PopupChallengeResult> in
                self.selectedAudience = audienceId
                return navigator.openAcceptConfirmation(type: .acceptOpponentOpen(idAudience: audienceId))
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
        
        // MARK
        // Refuse button from Direct Challenge
        let refuse = refuseS
            .flatMapLatest { [unowned self] (_) -> Observable<PopupChallengeResult> in
                if (self.data.progress == .waitingOpponent || self.data.progress == .waitingConfirmation) && self.data.type == .directChallenge {
                    return navigator.openAcceptConfirmation(type: .refuseDirect)
                }
                return Observable.empty()
            }
            .flatMap({ [weak self] (result) -> Observable<Bool> in
                guard let `self` = self else { return Observable.empty() }
                switch result {
                case .oke(let reason):
                    return self.putDirectReject(id: data.id, reason: reason)
                case .cancel:
                    return Observable.empty()
                }
            })
            .filter({ $0 })
            .flatMap({ _ in self.getChallengeDetail(id: data.id )})
            .do(onNext: { [weak self] (challenge) in
                guard let `self` = self else { return }
                self.challengeS.onNext(challenge)
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        // MARK
        // Share activity controller output
        let share = shareS
            .flatMapLatest({ navigator.shareChallenge(challenge: data )})
            .asDriverOnErrorJustComplete()
        
        // MARK
        // More button output
        let more = moreS
            .asObservable()
            .asDriverOnErrorJustComplete()
        
        let moreMenuSelected = moreMenuS
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .hapus(let id):
                    return navigator.deleteChallenge(challengeId: id)
                        .flatMap({ (result) -> Observable<String> in
                            switch result {
                            case .ok(let data):
                                return self.handleDeleteChallenge(challengeId: data)
                            default: return Observable.empty()
                            }
                        })
                        .map({ (_) -> String in
                            return ""
                        })
                case .salin:
                    return Observable.just("Tautan telah tersalin")
                case .share(let data):
                    return navigator.shareChallenge(challenge: data)
                        .map({ (_) -> String in
                            return ""
                        })
                }
        }.asDriverOnErrorJustComplete()
        
        let putLove = loveS
            .flatMapLatest({ [unowned self] in self.putLove(id: self.data.id) })
            .do(onNext: { [weak self](isSuccess) in
                guard let `self` = self else { return }
                if !isSuccess {
                    return
                }
                
                var challenge = data
                challenge.isLiked = true
                challenge.likeCount = (challenge.likeCount ?? 0) + 1
                
                self.challengeS.onNext(challenge)
            })
            .asDriverOnErrorJustComplete()
            .mapToVoid()
        
        /// Need configuration coordination result, after delete challenge need know item index
        let backSelected = backS.map({ ChallengeDetailResult.cancel })
        let deleteSelected = deleteS
            .map{ (result) in ChallengeDetailResult.result(id: result) }
        let closeSelected = Observable.merge(backSelected, deleteSelected)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        
        output = Output(backO: closeSelected,
                        actionO: action,
                        challengeO: challenge,
                        audienceO: audience,
                        confirmOpponentO: confirmOpponent,
                        refuseO: refuse,
                        shareO: share,
                        moreO: more,
                        moreMenuO: moreMenuSelected,
                        loveO: putLove)
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
            
            // in case direct challenge as opponent accept challenge
            if data.type == .directChallenge && (data.progress == .waitingOpponent || data.progress == .waitingConfirmation) && !isMyChallenge {
                return putDirectAccept(id: data.id)
            }
            
            return Observable.just(false)
        case .cancel: //when dismiss/negative button tap just return false to dismiss and do nothing
            return Observable.just(false)
        }
    }
    // MARK
    // Handle Accept Direct from opponents sides
    private func putDirectAccept(id: String) -> Observable<Bool> {
        return NetworkService.instance
            .requestObject(WordstadiumAPI.confirmDirect(challengeId: id), c: PutAskAsOpponentResponse.self)
            .map({ (response) -> Bool in
                return response.data.message == "Tantangan Diterima!"
            })
            .asObservable()
    }
    
    private func putLove(id: String) -> Observable<Bool> {
        return NetworkService.instance
            .requestObject(WordstadiumAPI.loveChallenge(challengeId: id), c: BaseResponse<CreateChallengeResponse>.self)
            .map({ $0.data.challenge.isLiked ?? false })
            .asObservable()
    }

    // MARK
    // Handle Reject Direct with reason from opponents sides
    private func putDirectReject(id: String, reason: String) -> Observable<Bool> {
        return NetworkService.instance
            .requestObject(WordstadiumAPI.rejectDirect(challengeId: id, reason: reason), c: PutAskAsOpponentResponse.self)
            .map({ (response) -> Bool in
                return response.data.message == "Tantangan Ditolak!"
            })
            .asObservable()
    }
    
    // MARK: - Handle delete challenge
    private func handleDeleteChallenge(challengeId: String) -> Observable<String> {
        return NetworkService.instance
            .requestObject(WordstadiumAPI.deleteOpenChallenge(challengeId: challengeId),
                           c: DeleteChallengeResponse.self)
            .map({ (response) -> String in
                return response.data.message
            })
            .do(onSuccess: { [unowned self] (_) in
                self.deleteS.onNext(challengeId)
            })
            .asObservable()
            .trackActivity(self.activityIndicator)
            .trackError(self.errorTracker)
    }
}
