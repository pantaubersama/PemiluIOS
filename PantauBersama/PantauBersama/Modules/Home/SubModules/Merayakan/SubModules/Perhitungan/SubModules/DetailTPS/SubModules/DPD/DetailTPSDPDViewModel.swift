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
    }
    
    struct Output {
        let backO: Driver<Void>
        let items: Driver<[SectionModelDPD]>
        let candidatePartyCountO: Driver<[CandidatePartyCount]>
        let suaraSahO: Driver<Int>
        let suaraInvalidO: Driver<Int>
        let totalSuaraO: Driver<Int>
        let dapilName: Driver<String>
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
    
    private let itemsRelay = BehaviorRelay<[SectionModelDPD]>(value: [])
    private let candidatesParty = BehaviorRelay<[CandidatePartyCount]>(value: [])
    private let suaraSahRelay = BehaviorRelay<Int>(value: 0)
    
    init(navigator: DetailTPSDPDNavigator, data: RealCount, tingkat: TingkatPemilihan) {
        self.navigator = navigator
        self.data = data
        self.tingkat = tingkat
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      counterI: counterS.asObserver(),
                      lastValueI: lastValueS.asObserver(),
                      invalidValueI: invalidValueS.asObserver())
        
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
        /// Counter mechanism
        let updateItems = counterS
            .flatMapLatest { [weak self] (candidateCount) -> Observable<[SectionModelDPD]> in
                guard let `self` = self else { return Observable.empty() }
                /// TODO
                /// Latest candidates uses for sum each row to drive into footer views
                var latestCandidates = self.candidatesParty.value
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
                    self.itemsRelay.accept(latestValue)
                }
                return Observable.just(latestValue)
            }
        
        /// Merge data with updates items
        let latestItems = Observable.merge(datas, updateItems)
            .asDriverOnErrorJustComplete()
        
        
        /// total suara sahO
        let totalSuaraSah = lastValueS
            .flatMapLatest { (a) -> Observable<Int> in
                return Observable.just(a)
            }.asDriverOnErrorJustComplete()
        
        /// invalid suara sahO
        let totalInvalidSuara = invalidValueS
            .asDriverOnErrorJustComplete()
        
        /// total suara, merge all invalid and valid
        let totalSuara = Observable.combineLatest(lastValueS.asObservable().startWith(0),
                                                  invalidValueS.asObservable().startWith(0))
            .flatMapLatest { (a,b) -> Observable<Int> in
                return Observable.just(a + b)
            }.asDriverOnErrorJustComplete()
        
        output = Output(backO: back,
                        items: latestItems,
                        candidatePartyCountO: candidatesParty.asDriverOnErrorJustComplete(),
                        suaraSahO: totalSuaraSah,
                        suaraInvalidO: totalInvalidSuara,
                        totalSuaraO: totalSuara,
                        dapilName: dapilName)
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
            candidate.append(CandidateActor(id: datas.id,
                                            name: datas.name,
                                            value: 0))
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
