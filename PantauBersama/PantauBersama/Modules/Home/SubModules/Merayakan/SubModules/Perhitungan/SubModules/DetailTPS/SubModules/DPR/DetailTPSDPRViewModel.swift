//
//  DetailTPSDPRViewModel.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

struct SectionTotalValue {
    var section: Int
    var totalValue: Int
}

class DetailTPSDPRViewModel: ViewModelType {
    
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
        let counterI: BehaviorSubject<CandidatePartyCount>
        let invalidCountI: AnyObserver<Int>
        let counterPartyI: AnyObserver<PartyCount>
    }
    
    struct Output {
        let backO: Driver<Void>
        let itemsO: Driver<[SectionModelDPR]>
        let nameDapilO: Driver<String>
        let counterO: Driver<CandidatePartyCount>
        let errorO: Driver<Error>
        let invalidO: Driver<Int>
        let counterPartyO: Driver<PartyCount>
        let initialValueO: Driver<RealCountResponse>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSDPRNavigator
    private let realCount: RealCount
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let nameDapilS = BehaviorRelay<String>(value: "")
    private let counterS = BehaviorSubject<CandidatePartyCount>(value: CandidatePartyCount(id: 0, totalVote: 0, indexPath: IndexPath(row: 0, section: 0)))
    private let candidatesValue = BehaviorRelay<[CandidatesCount]>(value: [])
    private let invalidCountS = PublishSubject<Int>()
    private let counterPartyS = PublishSubject<PartyCount>()
    
    var candidatesPartyValue = BehaviorRelay<[CandidatePartyCount]>(value: [])
    var bufferInvalid = BehaviorRelay<Int>(value: 0)
    var bufferTotal = BehaviorRelay<Int>(value: 0)
    var bufferItemActor = BehaviorRelay<[ItemActor]>(value: [])
    
    init(navigator: DetailTPSDPRNavigator, realCount: RealCount) {
        self.navigator = navigator
        self.realCount = realCount
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      counterI: counterS.asObserver(),
                      invalidCountI: invalidCountS.asObserver(),
                      counterPartyI: counterPartyS.asObserver())
        
        
        /// TODO
        /// Get data realcount calculations saved
        let initialValue = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<RealCountResponse> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getCalculations(hitungRealCountId: self.realCount.id,
                                                             tingkat: .dpr),
                                   c: BaseResponse<RealCountResponse>.self)
                    .map({ $0.data })
                    .do(onSuccess: { (response) in
                        print("Response candidates: \(response.calculation.candidates ?? [])")
                        self.bufferItemActor.accept(response.calculation.candidates ?? [])
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }.asDriverOnErrorJustComplete()
        
        
        /// TODO
        /// Get dapils by region to get id dapils
        /// Then fetch Candidates to get item
        let data = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[CandidateResponse]> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getDapils(provinceCode: self.realCount.provinceCode,
                                                       regenciCode: self.realCount.regencyCode,
                                                       districtCode: self.realCount.districtCode,
                                                       tingkat: .dpr)
                        , c: BaseResponse<DapilRegionResponse>.self)
                    .map({ $0.data })
                    .do(onSuccess: { [weak self] (response) in
                        guard let `self` = self else { return }
                        print("Dapil response: \(response)")
                        self.nameDapilS.accept(response.nama)
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .flatMapLatest({ [weak self] (dapilResponse) -> Observable<[CandidateResponse]> in
                        guard let `self` = self else { return Observable.empty() }
                        return self.getCandidates(idDapils: dapilResponse.id)
                    })
                    .asObservable()
        }
        
        let items = data
            .flatMapLatest { (response) -> Observable<[SectionModelDPR]> in
                return self.transformToSection(response: response)
        }.asDriverOnErrorJustComplete()
        
        /// Counter Mechanism
        /// TODO: Need Id and total value
        
        let counter = counterS
            .flatMapLatest({ [weak self] (candidatCount) -> Observable<CandidatePartyCount> in
                guard let `self` = self else { return Observable.empty() }
                
                var latestValue = self.candidatesValue.value
                latestValue.append(CandidatesCount(id: candidatCount.id, totalVote: candidatCount.totalVote))
               
                var latestCandidates = self.candidatesPartyValue.value
                latestCandidates.append(candidatCount)
                self.candidatesPartyValue.accept(latestCandidates)
                
                
                
                return Observable.just(candidatCount)
            })
            .asDriverOnErrorJustComplete()
        
        let invalid = invalidCountS
            .flatMapLatest { [weak self] (value) -> Observable<Int> in
                guard let `self` = self else { return Observable.empty() }
                self.bufferInvalid.accept(value)
                return Observable.just(value)
        }.asDriverOnErrorJustComplete()
        
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let partyCount = counterPartyS
            .flatMapLatest({ [weak self] (party) -> Observable<PartyCount> in
                guard let `self` = self else { return Observable.empty() }
                print(party)
                return Observable.just(party)
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back,
                        itemsO: items,
                        nameDapilO: nameDapilS.asDriverOnErrorJustComplete(),
                        counterO: counter,
                        errorO: errorTracker.asDriver(),
                        invalidO: invalid,
                        counterPartyO: partyCount,
                        initialValueO: initialValue)
    }
}


extension DetailTPSDPRViewModel {
    
    /// MARK: - Handle List All Candidates
    private func getCandidates(idDapils: Int) -> Observable<[CandidateResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getCandidates(dapilId: idDapils, tingkat: .dpr),
                           c: BaseResponses<CandidateResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                print("Response: \(response)")
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .asObservable()
    }
    
    private func transformToSection(response: [CandidateResponse]) -> Observable<[SectionModelDPR]> {
        var items: [SectionModelDPR] = []
        
        for item in response {
            items.append(SectionModelDPR(header: item.name,
                                         number: item.serialNumber,
                                         logo: item.logo?.thumbnail.url ?? "",
                                         items: item.candidates ?? []))
        }
        return Observable.just(items)
    }
}
