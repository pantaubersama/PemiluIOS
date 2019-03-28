//
//  HitungSuaraPresidenViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class DetailTPSPresidenViewModel: ViewModelType {
    
    struct Input {
        let backI: AnyObserver<Void>
        let suara1I: PublishSubject<Int>
        let suara2I: PublishSubject<Int>
        let suara3I: PublishSubject<Int> // for tidak sah
        let sendI: PublishSubject<Void>
        let invalidI: PublishSubject<Int>
    }
    
    struct Output {
        let backO: Driver<Void>
        let sendO: Driver<Void>
        let suara1O: Driver<Int>
        let suara2O: Driver<Int>
        let suara3O: Driver<Int>
        let invalidO: Driver<Int>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSPresidenNavigator
    private let uuid: String
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let suara1Subject = PublishSubject<Int>()
    private let suara2Subject = PublishSubject<Int>()
    private let suara3Subject = PublishSubject<Int>()
    private let sendSubject = PublishSubject<Void>()
    private let invalidSubject = PublishSubject<Int>()
    
    private let candidatesCount = BehaviorRelay(value: [CandidatesCount]())
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: DetailTPSPresidenNavigator, uuid: String) {
        self.navigator = navigator
        self.uuid = uuid
        
        input = Input(backI: backS.asObserver(),
                      suara1I: suara1Subject.asObserver(),
                      suara2I: suara2Subject.asObserver(),
                      suara3I: suara3Subject.asObserver(),
                      sendI: sendSubject.asObserver(),
                      invalidI: invalidSubject.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        /// When suara 1 triggered, store values with id 1 and value
        let suara1 = suara1Subject
            .flatMapLatest { [weak self] (value) -> Observable<Int> in
                guard let `self` = self else { return Observable.empty() }
                self.candidatesCount.accept([CandidatesCount(id: 1, totalVote: value)])
                return Observable.just(value)
        }.asDriverOnErrorJustComplete()
        
        /// When suara 2 triggered, store values with id 2 and value
        let suara2 = suara2Subject
            .flatMapLatest { [weak self] (value) -> Observable<Int> in
                guard let `self` = self else { return Observable.empty() }
                self.candidatesCount.accept([CandidatesCount(id: 2, totalVote: value)])
                return Observable.just(value)
            }.asDriverOnErrorJustComplete()
        
        
        /// TODO: Send actions
        let send = sendSubject
            .withLatestFrom(Observable.combineLatest(self.candidatesCount, invalidSubject))
            .flatMapLatest { [weak self] (c, i) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI
                        .putCalculations(parameters: [
                            "hitung_real_count_id": uuid,
                            "calculation_type": "presiden",
                            "invalid_vote": i,
                            "candidates": c.dictionary as Any
                            ]), c: BaseResponse<RealCountResponse>.self)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustComplete()
                    .mapToVoid()
        }
        
        
        output = Output(backO: back,
                        sendO: send.asDriverOnErrorJustComplete(),
                        suara1O: suara1,
                        suara2O: suara2,
                        suara3O: suara3Subject.asDriverOnErrorJustComplete(),
                        invalidO: invalidSubject.asDriverOnErrorJustComplete())
    }
}

// Object to save candidates in presiden real count
struct CandidatesCount {
    var id: Int
    var totalVote: Int

    init(id: Int, totalVote: Int) {
        self.id = id
        self.totalVote = totalVote
    }
}

extension CandidatesCount: Encodable { }
