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
        let suara1I: AnyObserver<Int>
        let suara2I: AnyObserver<Int>
        let suara3I: AnyObserver<Int> // for tidak sah
        let sendI: AnyObserver<Void>
        let invalidI: AnyObserver<Int>
        let totalInvalidI: AnyObserver<Int>
        let totalValidValueI: AnyObserver<Int>
        let totalValueI: AnyObserver<Int>
        let refreshI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let sendO: Driver<Void>
        let suara1O: Driver<Int>
        let suara2O: Driver<Int>
        let suara3O: Driver<Int>
        let invalidO: Driver<Int>
        let totalSuaraO: Driver<Int>
        let totalValidO: Driver<Int>
        let dataO: Driver<Calculation>
        let errorO: Driver<Error>
        let realCountO: Driver<RealCount>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSPresidenNavigator
    private let data: RealCount
    
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let suara1Subject = PublishSubject<Int>()
    private let suara2Subject = PublishSubject<Int>()
    private let suara3Subject = PublishSubject<Int>()
    private let sendSubject = PublishSubject<Void>()
    private let invalidSubject = PublishSubject<Int>()
    private let totalInvalidSubject = PublishSubject<Int>()
    private let totalValidValueSubject = PublishSubject<Int>()
    private let totalValueSubject = PublishSubject<Int>()
    private let refreshSubject = PublishSubject<String>()
    
    private let candidatesCount = BehaviorRelay<[CandidatesCount]>(value: [])
    private let bufferCandidate1 = BehaviorRelay<Int>(value: 0)
    private let bufferCandidate2 = BehaviorRelay<Int>(value: 0)
    var bufferInvalid = BehaviorRelay<Int>(value: 0)
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: DetailTPSPresidenNavigator, data: RealCount) {
        self.navigator = navigator
        self.data = data
        
        input = Input(backI: backS.asObserver(),
                      suara1I: suara1Subject.asObserver(),
                      suara2I: suara2Subject.asObserver(),
                      suara3I: suara3Subject.asObserver(),
                      sendI: sendSubject.asObserver(),
                      invalidI: invalidSubject.asObserver(),
                      totalInvalidI: totalInvalidSubject.asObserver(),
                      totalValidValueI: totalValidValueSubject.asObserver(),
                      totalValueI: totalValueSubject.asObserver(),
                      refreshI: refreshSubject.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        /// Get data from latest value
        let data = refreshSubject.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<Calculation> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI
                        .getCalculations(
                            hitungRealCountId: self.data.id,
                            tingkat: .presiden),
                                   c: BaseResponse<RealCountResponse>.self)
                    .map({ $0.data.calculation })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
        }.asDriverOnErrorJustComplete()
        
        
        /// When suara 1 triggered, store values with id 1 and value
        let suara1 = suara1Subject
            .flatMapLatest { [weak self] (value) -> Observable<Int> in
                guard let `self` = self else { return Observable.empty() }
                self.bufferCandidate1.accept(value)
                
                return Observable.just(value)
        }.asDriverOnErrorJustComplete()
        
        /// When suara 2 triggered, store values with id 2 and value
        let suara2 = suara2Subject
            .flatMapLatest { [weak self] (value) -> Observable<Int> in
                guard let `self` = self else { return Observable.empty() }
                self.bufferCandidate2.accept(value)
                return Observable.just(value)
            }.asDriverOnErrorJustComplete()
        
        
        /// When suara 3 triggered
        let suara3 = suara3Subject
            .flatMapLatest { [weak self] (value) -> Observable<Int> in
                guard let `self` = self else { return Observable.empty() }
                self.bufferInvalid.accept(value)
                return Observable.just(value)
        }.asDriverOnErrorJustComplete()
        
        /// TODO: Send actions need wait observable with 2 conditions
        /// If conditions not fullfiled then disable send button
        /// Need configuration array JSON Object candidates
        /// Currently this config support for multipartForm data
        let send = sendSubject
            .withLatestFrom(Observable.combineLatest(self.candidatesCount,
                                                     suara3Subject.asObservable().startWith(0)))
            .flatMapLatest { [weak self] (c, i) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                var latestValue = c
                latestValue.append(CandidatesCount(id: 1, totalVote: self.bufferCandidate1.value))
                latestValue.append(CandidatesCount(id: 2, totalVote: self.bufferCandidate2.value))
                return NetworkService.instance
                    .requestObject(HitungAPI.putCalculations(hitungRealCountId: self.data.id,
                                                             type: .presiden,
                                                             invalidVote: i,
                                                             candidates: latestValue,
                                                             parties: nil),
                                   c: BaseResponse<RealCountResponse>.self)
                    .do(onSuccess: { (_) in
                        self.navigator.showSuccess()
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .mapToVoid()
        }
        
        // Trigger whenever values changes all values
        let totalSuaraO = Observable.merge(suara1Subject.asObservable(),
                                           suara2Subject.asObservable(),
                                           suara3Subject.asObservable())
            .map({ [unowned self] (values) -> Int in
                return self.bufferInvalid.value + self.bufferCandidate1.value + self.bufferCandidate2.value
            })
            .asDriverOnErrorJustComplete()
        
        let totalValidSuaraO = Observable.merge(suara1Subject.asObservable(),
                                                suara2Subject.asObservable())
            .map { [unowned self] (values) -> Int in
                return self.bufferCandidate1.value + self.bufferCandidate2.value
        }.asDriverOnErrorJustComplete()
        
        output = Output(backO: back,
                        sendO: send.asDriverOnErrorJustComplete(),
                        suara1O: suara1,
                        suara2O: suara2,
                        suara3O: suara3,
                        invalidO: invalidSubject.asDriverOnErrorJustComplete(),
                        totalSuaraO: totalSuaraO,
                        totalValidO: totalValidSuaraO,
                        dataO: data,
                        errorO: errorTracker.asDriver(),
                        realCountO: Driver.just(self.data))
    }
}

