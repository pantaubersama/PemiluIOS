//
//  DetailAskViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

enum DetailAskResult {
    case done(data: Question, change: Int)
}

final class DetailAskViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    
    struct Input {
        let backI: AnyObserver<Void>
        let shareI: AnyObserver<Question>
        let moreI: AnyObserver<Question>
        let moreMenuI: AnyObserver<QuestionSingleType>
        let voteI: AnyObserver<Question?>
        let unvoteI: AnyObserver<Question?>
        let viewWillAppearI: AnyObserver<Void>
        let voteTriggerI: AnyObserver<Void>
        let profileTrigger: AnyObserver<UITapGestureRecognizer>
    }
    
    struct Output {
        let itemsO: Driver<Question>
        let moreO: Driver<Question>
        let moreMenuO: Driver<String>
        let shareO: Driver<Void>
        let deleteO: Driver<Int>
        let voteO: Driver<(Bool)>
        let unvoteO: Driver<Bool>
        let profileO: Driver<Void>
        let backO: Driver<DetailAskResult>
    }
    
    private let backS = PublishSubject<Void>()
    private let shareS = PublishSubject<Question>()
    private let moreS = PublishSubject<Question>()
    private let moreMenuS = PublishSubject<QuestionSingleType>()
    private let voteS = PublishSubject<Question?>()
    private let unvoteS = PublishSubject<Question?>()
    private let deleteS = PublishSubject<Int>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let voteTriggerS = PublishSubject<Void>()
    private let profileS = PublishSubject<UITapGestureRecognizer>()
    
    private let data: String
    private var navigator: DetailAskNavigaor
    
    init(navigator: DetailAskNavigaor, data: String) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.data = data
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        input = Input(
            backI: backS.asObserver(),
            shareI: shareS.asObserver(),
            moreI: moreS.asObserver(),
            moreMenuI: moreMenuS.asObserver(),
            voteI: voteS.asObserver(),
            unvoteI: unvoteS.asObserver(),
            viewWillAppearI: viewWillAppearS.asObserver(),
            voteTriggerI: voteTriggerS.asObserver(),
            profileTrigger: profileS.asObserver()
        )
        
        // MARK
        // If from share need to know data result
        // parameter Id
        let dataQuestion = Observable.merge(viewWillAppearS, voteTriggerS)
            .flatMapLatest { (_) -> Observable<Question> in
                return NetworkService.instance
                    .requestObject(TanyaKandidatAPI.getQuestionsId(id: data),
                                   c: BaseResponse<SingleQuestionResponse>.self)
                    .map({ $0.data.question })
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
            }
        
        let moreMenu = moreMenuS
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .bagikan(let question):
                    let contentToShare = question.id
                    return navigator.shareQuestion(question: contentToShare)
                        .map({ (_) -> String in
                            return ""
                        })
                case .hapus(let question):
                    return deleteQuestion(question: question)
                        .map({ (result) -> String in
                            return result.status ? "delete succeeded" : "delete failed"
                        })
                case .laporkan(let question):
                    return reportQuestion(question: question)
                case .salin(let question):
                    let data = "\(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/tanya/\(question.id)"
                    data.copyToClipboard()
                    return Observable.just("Tautan telah tersalin")
                }
            }.asDriverOnErrorJustComplete()
        
        let share = shareS
            .flatMapLatest({ navigator.shareQuestion(question: $0.id) })
            .asDriverOnErrorJustComplete()
        
        var change: Int = 0 // for not upvote and unvote
        let vote = voteS
            .flatMapLatest({ voteQuestion(question: $0) })
            .do(onNext: { (_) in
                change = 1
            })
            .asDriverOnErrorJustComplete()
        
        let unvote = unvoteS
            .flatMapLatest({ deleteVoteQuestion(question: $0) })
            .do(onNext: { (_) in
                change = 2
            })
            .asDriverOnErrorJustComplete()
        
        let profile = profileS
            .withLatestFrom(dataQuestion)
            .flatMapLatest({ (question) -> Observable<Void> in
                if let myId = AppState.local()?.user.id {
                    if myId == question.user?.id {
                        return navigator.launchProfileUser(isMyAccount: true, userId: nil)
                    } else {
                        return navigator.launchProfileUser(isMyAccount: false, userId: question.user?.id)
                    }
                }
                return Observable.empty()
            })
            .asDriverOnErrorJustComplete()
        
        
        let back = backS
            .withLatestFrom(dataQuestion)
            .map({ (result) in DetailAskResult.done(data: result, change: change) })
        
        let backSelected = back
            .take(1)
            .asDriverOnErrorJustComplete()
        
        output = Output(
            itemsO: dataQuestion.asDriverOnErrorJustComplete(),
            moreO: moreS.asDriverOnErrorJustComplete(),
            moreMenuO: moreMenu,
            shareO: share,
            deleteO: deleteS.asDriverOnErrorJustComplete(),
            voteO: vote,
            unvoteO: unvote,
            profileO: profile,
            backO: backSelected
        )
        
        
        func deleteQuestion(question: Question?) -> Observable<(question: QuestionModel, status: Bool)> {
            return NetworkService.instance
                .requestObject(TanyaKandidatAPI.deleteQuestion(id: question?.id ?? ""
                ), c: QuestionResponse.self)
                .map({ (response) -> (question: QuestionModel, status: Bool) in
                    let questionModel = QuestionModel(question: response.data.question)
                    let status = response.data.status
                    
                    return (questionModel, status)
                })
                .asObservable()
                .catchErrorJustComplete()
        }
        
        func voteQuestion(question: Question?) -> Observable<Bool> {
            return NetworkService.instance
                .requestObject(TanyaKandidatAPI.voteQuestion(id: question?.id ?? "", className: "Question"), c: QuestionOptionResponse.self)
                .map({ (response) -> (Bool) in
                    let status = response.data.vote.status
                    
                    return status
                })
                .asObservable()
                .catchErrorJustComplete()
        }
        
        func deleteVoteQuestion(question: Question?) -> Observable<Bool> {
            return NetworkService.instance
                .requestObject(TanyaKandidatAPI.deleteVoteQuestion(id: question?.id ?? "", className: "Question"), c: QuestionOptionResponse.self)
                .map({ (response) -> Bool in
                    let status = response.data.vote.status
                    return status
                })
                .asObservable()
                .catchErrorJustComplete()
        }
        
        
        func reportQuestion(question: Question) -> Observable<String> {
            // TODO: make sure what is className
            return NetworkService.instance
                .requestObject(TanyaKandidatAPI.reportQuestion(id: question.id, className: "Question"), c: QuestionOptionResponse.self)
                .map { (response) -> String in
                    return response.data.vote.status ? "laporan berhasil" : response.data.vote.text
                }
                .asObservable()
                .catchErrorJustReturn("Terjadi kesalahan")
        }
    }
    
    
    
}



