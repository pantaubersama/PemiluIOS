//
//  DetailTPSDPDViewModel.swift
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
import RxDataSources

class DetailTPSDPDViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
        let counterI: AnyObserver<CandidatePartyCount>
        let lastValueI: AnyObserver<Int>
        let invalidValueI: AnyObserver<Int>
        let simpanI: AnyObserver<Void>
        let viewWillAppearI: AnyObserver<Void>
        let initialLastI: AnyObserver<Int>
    }
    
    struct Output {
        let backO: Driver<Void>
        let items: Driver<[SectionModelDPD]>
        let candidatePartyCountO: Driver<[CandidatePartyCount]>
        let suaraSahO: Driver<Int>
        let suaraInvalidO: Driver<Int>
        let totalSuaraO: Driver<Int>
        let dapilName: Driver<String>
        let simapnO: Driver<Void>
        let errorO: Driver<Error>
        let initialO: Driver<Void>
        let realCountO: Driver<RealCount>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSDPDNavigator
    private let data: RealCount
    private let tingkat: TingkatPemilihan
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let refreshS = PublishSubject<String>()
    private let counterS = PublishSubject<CandidatePartyCount>()
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let lastValueS = PublishSubject<Int>()
    private let invalidValueS = PublishSubject<Int>()
    private let simpanS = PublishSubject<Void>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let initialLastS = PublishSubject<Int>()
    
    private let itemsRelay = BehaviorRelay<[SectionModelDPD]>(value: [])
    private let candidatesParty = BehaviorRelay<[CandidatePartyCount]>(value: [])
    private let suaraSahRelay = BehaviorRelay<Int>(value: 0)
    var candidateActorRelay = BehaviorRelay<[ItemActor]>(value: [])
    
    init(navigator: DetailTPSDPDNavigator, data: RealCount, tingkat: TingkatPemilihan) {
        self.navigator = navigator
        self.data = data
        self.tingkat = tingkat
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      counterI: counterS.asObserver(),
                      lastValueI: lastValueS.asObserver(),
                      invalidValueI: invalidValueS.asObserver(),
                      simpanI: simpanS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      initialLastI: initialLastS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        /// TODO
        /// Fetch dapil name
        let dapilName = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<String> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getDapils(provinceCode: self.data.provinceCode,
                                                       regenciCode: self.data.regencyCode,
                                                       districtCode: self.data.districtCode,
                                                       tingkat: self.tingkat)
                        , c: BaseResponse<DapilRegionResponse>.self)
                    .map({ $0.data.nama })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }.asDriverOnErrorJustComplete()
        
        
        /// TODO
        /// GET Section All Dapil and Candidates
        let datas = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[CandidateDPDResponse]> in
                guard let `self` = self else { return Observable.empty() }
                return self.getDapils(tingkat: self.tingkat)
            }
            .flatMapLatest { [weak self] (response) -> Observable<[SectionModelDPD]> in
                guard let `self` = self else { return Observable.empty() }
                return self.transformToSection(response: response)
            }
        
        /// TODO
        /// GET Initial value
        let initialValue = viewWillAppearS
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getCalculations(hitungRealCountId: self.data.id, tingkat: self.tingkat),
                                   c: BaseResponse<RealCountResponse>.self)
                    .map({ $0.data })
                    .do(onSuccess: { [weak self] (response) in
                        guard let `self` = self else { return }
                        self.invalidValueS.onNext(response.calculation.invalidVote)
                        let lastValue = response.calculation.candidates?.map({ $0.totalVote ?? 0 }).reduce(0, +)
                        self.initialLastS.onNext(lastValue ?? 0)
                        self.candidateActorRelay.accept(response.calculation.candidates ?? [])
                        
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .mapToVoid()
        }.asDriverOnErrorJustComplete()
        
        
        /// TODO
        /// Counter mechanism
        let updateItems = counterS
            .flatMapLatest { [weak self] (candidateCount) -> Observable<[SectionModelDPD]> in
                guard let `self` = self else { return Observable.empty() }
                /// TODO
                /// Latest candidates uses for sum each row to drive into footer views
                var latestCandidates = self.candidatesParty.value
                var initialCandidates = self.candidateActorRelay.value
                /// I Assume we need clear our initial data here, little buggy >,<
                if initialCandidates.contains(where: { $0.actorId == "\(candidateCount.id)" }) {
                    guard let index = initialCandidates.index(where: { current -> Bool in
                        return current.actorId == "\(candidateCount.id)"
                    }) else { return Observable.empty() }
                    print("Same id, must clear in initial value at index: \(index)")
                    initialCandidates.remove(at: index)
                    print("Initial count = \(initialCandidates.count)")
                    let sumInitial = initialCandidates.map({ $0.totalVote ?? 0}).reduce(0, +)
                    self.initialLastS.onNext(sumInitial)
                    self.candidateActorRelay.accept(initialCandidates)
                }
                /// filter if id is match then remove and append with latest values
                if latestCandidates.contains(where: { $0.id == candidateCount.id }) {
                    guard let index = latestCandidates.index(where: { current -> Bool in
                        return current.id == candidateCount.id
                    }) else { return Observable.empty() }
                    latestCandidates.remove(at: index)
                    latestCandidates.append(candidateCount)
                } else {
                    /// if id not match just append
                    latestCandidates.append(candidateCount)
                }
                /// accept latest candidates with latest values candidate count
                self.candidatesParty.accept(latestCandidates)
                
                /// TODO
                /// match latest value for section table view, this function will keep cell [Items] into latest values
                var latestValue = self.itemsRelay.value
                var currentCandidate = latestValue[candidateCount.indexPath.section]
                /// find index of section models in row
                guard let index = currentCandidate.items.index(where: { current -> Bool in
                    return current.id == candidateCount.id
                }) else { return Observable.empty() }
                
                var updateCandidate = currentCandidate.items.filter{ (candidate) -> Bool in
                    return candidate.id == candidateCount.id
                }.first
                
                if updateCandidate != nil {
                    updateCandidate?.value = candidateCount.totalVote
                    currentCandidate.items[index] = updateCandidate!
                    latestValue[candidateCount.indexPath.section] = currentCandidate
                    /// accept [Items]
                    
                    print("Current update candidates: \(updateCandidate?.value ?? 0)")
                    
                    self.itemsRelay.accept(latestValue)
                }
                return Observable.just(latestValue)
            }
        
        /// Merge data with updates items
        let latestItems = Observable.merge(datas, updateItems)
            .asDriverOnErrorJustComplete()
        
        
        /// total suara sahO
        let totalSuaraSah = Observable.combineLatest(initialLastS.asObservable().startWith(0),
                                                     lastValueS.asObservable().startWith(0))
            .flatMapLatest { (a, b) -> Observable<Int> in
                return Observable.just(a + b)
            }.asDriverOnErrorJustComplete()
        
        /// invalid suara sahO
        let totalInvalidSuara = invalidValueS
            .asDriverOnErrorJustComplete()
        
        /// total suara, merge all invalid and valid
        let totalSuara = Observable.combineLatest(lastValueS.asObservable().startWith(0),
                                                  invalidValueS.asObservable().startWith(0),
                                                  initialLastS.asObservable().startWith(0))
            .flatMapLatest { (a, b, c) -> Observable<Int> in
                return Observable.just(a + b + c)
            }.asDriverOnErrorJustComplete()
        
        /// Save values
        let simpan = simpanS
            .withLatestFrom(Observable.combineLatest(invalidValueS.asObservable().startWith(0),
                                                     self.candidatesParty,
                                                     self.candidateActorRelay))
            .flatMapLatest { [weak self] (invalid, candidates, initialData) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }

                return NetworkService.instance
                    .requestObject(HitungAPI.putCalculationsCandidates(id: self.data.id,
                                                                       type: self.tingkat,
                                                                       invalidVote: invalid,
                                                                       candidates: candidates,
                                                                       parties: nil,
                                                                       initialData: initialData),
                                   c: BaseResponse<RealCountResponse>.self)
                    .do(onSuccess: { (_) in
                        navigator.showSuccess()
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .mapToVoid()
            }.asDriverOnErrorJustComplete()
        
        
        
        
        output = Output(backO: back,
                        items: latestItems,
                        candidatePartyCountO: candidatesParty.asDriverOnErrorJustComplete(),
                        suaraSahO: totalSuaraSah,
                        suaraInvalidO: totalInvalidSuara,
                        totalSuaraO: totalSuara,
                        dapilName: dapilName,
                        simapnO: simpan,
                        errorO: errorTracker.asDriver(),
                        initialO: initialValue,
                        realCountO: Driver.just(self.data))
    }
}


extension DetailTPSDPDViewModel {
    /// MARK: - Get Dapils Location
    private func getDapils(tingkat: TingkatPemilihan) -> Observable<[CandidateDPDResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getDapils(provinceCode: self.data.provinceCode,
                                               regenciCode: self.data.regencyCode,
                                               districtCode: self.data.districtCode,
                                               tingkat: tingkat),
                           c: BaseResponse<DapilRegionResponse>.self)
            .map({ $0.data })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .flatMapLatest({ self.getCandidates(idDapils: $0.id, tingkat: tingkat) })
            .asObservable()
    }
    /// MARK: - Handle List All Candidates
    private func getCandidates(idDapils: Int, tingkat: TingkatPemilihan) -> Observable<[CandidateDPDResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getCandidates(dapilId: idDapils, tingkat: tingkat),
                           c: BaseResponses<CandidateDPDResponse>.self)
            .map({ $0.data })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .asObservable()
    }
    /// MARK: - Transform to Sections
    private func transformToSection(response: [CandidateDPDResponse]) -> Observable<[SectionModelDPD]> {
        var items: [SectionModelDPD] = []
        for item in response {
            items.append(SectionModelDPD(header: item.nama,
                                         items: self.generateCandidates(data: item),
                                         total: 0))
        }
        self.itemsRelay.accept(items)
        return Observable.just(items)
    }
    /// MARK: - Generate candidates Actor
    private func generateCandidates(data: CandidateDPDResponse) -> [CandidateActor] {
        var candidate: [CandidateActor] = []
        
        for datas in data.candidates {
            let initialValue = self.candidateActorRelay.value.filter({ $0.actorId == "\(datas.id)"}).first?.totalVote
            candidate.append(CandidateActor(id: datas.id,
                                            name: datas.name,
                                            value: initialValue ?? 0,
                                            number: datas.number))
        }
        return candidate
    }
}


struct SectionModelDPD {
    var header: String
    var items: [Item]
    var total: Int
    
    init(header: String, items: [Item], total: Int) {
        self.header = header
        self.items = items
        self.total = total
    }
    
}

extension SectionModelDPD: SectionModelType {
    typealias Item = CandidateActor
    
    init(original: SectionModelDPD, items: [CandidateActor]) {
        self = original
        self.items = items
    }
}
