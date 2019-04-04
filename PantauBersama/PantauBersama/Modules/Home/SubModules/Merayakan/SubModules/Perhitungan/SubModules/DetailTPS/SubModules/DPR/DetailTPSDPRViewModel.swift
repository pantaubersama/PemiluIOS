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
        let counterI: AnyObserver<CandidatePartyCount>
        let invalidCountI: AnyObserver<Int>
        let counterPartyI: AnyObserver<PartyCount>
        let viewWillAppearI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let itemsO: Driver<[SectionModelDPR]>
        let nameDapilO: Driver<String>
        let errorO: Driver<Error>
        let invalidO: Driver<Int>
        let counterPartyO: Driver<PartyCount>
        let initialValueO: Driver<RealCountResponse>
        let dataO: Driver<Void>
        let updateItemsO: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSDPRNavigator
    private let realCount: RealCount
    private let type: TingkatPemilihan
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    private let refreshS = PublishSubject<String>()
    private let nameDapilS = BehaviorRelay<String>(value: "")
    private let counterS = PublishSubject<CandidatePartyCount>()
    private let candidatesValue = BehaviorRelay<[CandidatesCount]>(value: [])
    private let invalidCountS = PublishSubject<Int>()
    private let counterPartyS = PublishSubject<PartyCount>()
    private let viewWillAppearS = PublishSubject<Void>()
    
    private let itemsRelay = BehaviorRelay<[SectionModelDPR]>(value: [])
    
    var candidatesPartyValue = BehaviorRelay<[CandidatePartyCount]>(value: [])
    var bufferInvalid = BehaviorRelay<Int>(value: 0)
    var bufferTotal = BehaviorRelay<Int>(value: 0)
    var bufferItemActor = BehaviorRelay<[ItemActor]>(value: [])
    
    private(set) var disposeBag = DisposeBag()
    
    init(navigator: DetailTPSDPRNavigator, realCount: RealCount, type: TingkatPemilihan) {
        self.navigator = navigator
        self.realCount = realCount
        self.type = type
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver(),
                      counterI: counterS.asObserver(),
                      invalidCountI: invalidCountS.asObserver(),
                      counterPartyI: counterPartyS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver())
        
        
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
        let data = viewWillAppearS
            .flatMapLatest { [weak self] (_) -> Observable<[CandidateResponse]> in
                guard let `self` = self else { return Observable.empty() }
                return self.getDapils(tingkat: type)
            }.flatMapLatest { (response) -> Observable<[SectionModelDPR]> in
                return self.transformToSection(response: response)
            }.mapToVoid()
            .asDriverOnErrorJustComplete()
        
        /// Counter Mechanism
        /// TODO: Need Id and total value
//        counterS
//            .do(onNext: { [weak self] (candidatCount) in
//                guard let `self` = self else { return }
//                var latestValue = self.candidatesValue.value
//                latestValue.append(CandidatesCount(id: candidatCount.id, totalVote: candidatCount.totalVote))
//                
//                var latestCandidates = self.candidatesPartyValue.value
//                latestCandidates.append(candidatCount)
//                self.candidatesPartyValue.accept(latestCandidates)
//                
//                var currentRelayValue = self.itemsRelay.value
//                /// Updated sections
//                guard let section = currentRelayValue.index(where: { current -> Bool in
//                    return current.items[candidatCount.indexPath.row].id == candidatCount.id
//                }) else { return }
//                print(section)
//                /// Updated row in Section == candidates
//                let candidates = currentRelayValue[candidatCount.indexPath.section].items
//                guard let row = candidates.index(where: { current -> Bool in
//                    return current.id == candidatCount.id
//                }) else { return }
//                print(row)
//                
//                var updateCandidates = currentRelayValue[section].items[row]
//                    updateCandidates.value = candidatCount.totalVote
//                    currentRelayValue[section].items.remove(at: row)
//                currentRelayValue[section].items.insert(updateCandidates, at: row)
//                    self.itemsRelay.accept(currentRelayValue)
//                print(updateCandidates)
//            })
//            .bind { [weak self] candidatCount in
//            }
//            .disposed(by: disposeBag)
        
        let updateItems = counterS
            .flatMapLatest { [weak self] (candidateCount) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
//                var latestValue = self.itemsRelay.value
//
//                guard let sectionValue = latestValue.index(where: { current -> Bool in
//                    return current.items[candidateCount.indexPath.row].id == candidateCount.id
//                }) else { return Observable.empty() }
//                let candidates = latestValue[candidateCount.indexPath.section].items
//
//                guard let rowValue = candidates.index(where: { current -> Bool in
//                    return current.id == candidateCount.id
//                }) else { return Observable.empty() }
//
//                var updateValue = latestValue[sectionValue].items[rowValue]
//                updateValue.value = candidateCount.totalVote
//                latestValue[sectionValue].items.remove(at: rowValue)
//                latestValue[sectionValue].items.insert(updateValue, at: rowValue)
//                self.itemsRelay.accept(latestValue)
                
                var latestValue = self.candidatesPartyValue.value
                guard let index = latestValue.index(where: { current -> Bool in
                    return current.id == candidateCount.id
                }) else { return Observable.empty() }
                latestValue[index].totalVote = candidateCount.totalVote
                latestValue.remove(at: index)
                latestValue.insert(candidateCount, at: index)
                self.candidatesPartyValue.accept(latestValue)
                
                return Observable.just(())
        }.asDriverOnErrorJustComplete()
        
        
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
                        itemsO: itemsRelay.asDriverOnErrorJustComplete(),
                        nameDapilO: nameDapilS.asDriverOnErrorJustComplete(),
                        errorO: errorTracker.asDriver(),
                        invalidO: invalid,
                        counterPartyO: partyCount,
                        initialValueO: initialValue,
                        dataO: data,
                        updateItemsO: updateItems)
    }
}


extension DetailTPSDPRViewModel {
    /// MARK: - Get Dapils Location
    private func getDapils(tingkat: TingkatPemilihan) -> Observable<[CandidateResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getDapils(provinceCode: self.realCount.provinceCode,
                                               regenciCode: self.realCount.regencyCode,
                                               districtCode: self.realCount.districtCode,
                                               tingkat: tingkat),
                           c: BaseResponse<DapilRegionResponse>.self)
            .map({ $0.data })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .flatMapLatest({ self.getCandidates(idDapils: $0.id, tingkat: tingkat) })
            .asObservable()
    }
    /// MARK: - Handle List All Candidates
    private func getCandidates(idDapils: Int, tingkat: TingkatPemilihan) -> Observable<[CandidateResponse]> {
        return NetworkService.instance
            .requestObject(HitungAPI.getCandidates(dapilId: idDapils, tingkat: tingkat),
                           c: BaseResponses<CandidateResponse>.self)
            .map({ $0.data })
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
                                         items: self.generateCandidates(data: item,
                                                                        itemActor: self.candidatesPartyValue.value)))
        }
        self.itemsRelay.accept(items)
        return Observable.just(items)
    }
    
    private func generateCandidates(data: CandidateResponse, itemActor: [CandidatePartyCount]) -> [CandidateActor] {
        var candidate: [CandidateActor] = []
        print("Item actor: \(itemActor)")
        
        for datas in data.candidates ?? [] {
            candidate.append(CandidateActor(id: datas.id,
                                            name: datas.name ?? "",
                                            value: 0))
        }
        
        return candidate
    }
}
