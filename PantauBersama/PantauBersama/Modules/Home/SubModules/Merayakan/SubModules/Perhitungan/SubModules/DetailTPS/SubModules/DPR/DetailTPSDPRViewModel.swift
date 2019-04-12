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
        let bufferPartyI: AnyObserver<PartyCount>
    }
    
    struct Output {
        let backO: Driver<Void>
        let itemsO: Driver<[SectionModelDPR]>
        let nameDapilO: Driver<String>
        let errorO: Driver<Error>
        let invalidO: Driver<Int>
        let initialValueO: Driver<RealCountResponse>
        let dataO: Driver<Void>
        let updateItemsO: Driver<Void>
        
        let itemsSections: Driver<[SectionModelCalculations]>
        let bufferPartyO: Driver<PartyCount>
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
    private let bufferPartyS = PublishSubject<PartyCount>()
    
    private let itemsRelay = BehaviorRelay<[SectionModelDPR]>(value: [])
    private let itemRelay = BehaviorRelay<[SectionModelCalculations]>(value: [])
    
    var candidatesPartyValue = BehaviorRelay<[CandidatePartyCount]>(value: [])
    private let partyValue = BehaviorRelay<[PartyCount]>(value: [])
    
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
                      viewWillAppearI: viewWillAppearS.asObserver(),
                      bufferPartyI: bufferPartyS.asObserver())
        
        
        /// MARK
        /// GET Name Dapil
        let nameDapil = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<String> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getDapils(provinceCode: self.realCount.provinceCode,
                                                       regenciCode: self.realCount.regencyCode,
                                                       districtCode: self.realCount.districtCode,
                                                       tingkat: self.type),
                                   c: BaseResponse<DapilRegionResponse>.self)
                    .map({ $0.data.nama })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }.asDriverOnErrorJustComplete()
        
        /// MARK
        /// GET Data based Dapils to GET Candidates
        /// Then transform to SectionModelsCalculations
        let itemsSection = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[CandidateResponse]> in
                guard let `self` = self else { return Observable.empty() }
                return self.getDapils(tingkat: self.type)
            }
            .flatMapLatest { [weak self] (response) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                return self.transformToSectionsCalculations(response: response)
            }
        
        
        /// MARK
        /// TODO: Update ITEMS based on counter button
        let itemsUpdate = counterS
            .flatMapLatest { [weak self] (candidateCount) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                
                /// TODO
                /// Latest candidates use fo sum each row and append into sections models
                var latestCandidates = self.candidatesPartyValue.value
                /// filter if id is match, remove and append with latest values
                if latestCandidates.contains(where: { $0.id == candidateCount.id }) {
                    guard let index = latestCandidates.index(where: { current -> Bool in
                        return current.id == candidateCount.id
                    }) else { return Observable.empty() }
                    latestCandidates.remove(at: index)
                    latestCandidates.append(candidateCount)
                } else {
                    latestCandidates.append(candidateCount)
                }
                self.candidatesPartyValue.accept(latestCandidates)
                
                
                /// TODO
                /// Match latest value for section tableview, this func will keep cell [Items]
                /// based on his values
                var latestItems = self.itemRelay.value
                /// then match candidates with sections models
                var currentCandidates = latestItems[candidateCount.indexPath.section]
                /// find index of sections
                guard let index = currentCandidates.items.index(where: { current -> Bool in
                    return current.id == candidateCount.id
                }) else { return Observable.empty() }
                /// updated candidates
                var updateCandidate = currentCandidates.items.filter{ (candidate) -> Bool in
                    return candidate.id == candidateCount.id
                }.first
                
                if updateCandidate != nil {
                    updateCandidate?.value = candidateCount.totalVote
                    currentCandidates.items[index] = updateCandidate!
                    latestItems[candidateCount.indexPath.section] = currentCandidates
                    // after assign row and section, then keep into Relay Sections Models
                    self.itemRelay.accept(latestItems)
                }
                return Observable.just(latestItems)
        }
        
        
        /// MARK
        /// Update Header counter
        let headerUpdates = counterPartyS
            .flatMapLatest { [weak self] (partyCount) -> Observable<[SectionModelCalculations]> in
                guard let `self` = self else { return Observable.empty() }
                
                // TODO
                // Fetch latest party values
                var latestPartyValue = self.partyValue.value
                
                if latestPartyValue.contains(where: { $0.number == partyCount.number }) {
                    guard let index = latestPartyValue.index(where: { current -> Bool in
                        return current.number == partyCount.number
                    }) else { return Observable.empty() }
                    latestPartyValue.remove(at: index)
                    latestPartyValue.append(partyCount)
                } else {
                    latestPartyValue.append(partyCount)
                }
                self.partyValue.accept(latestPartyValue)
                
                /// Match with latest items
                var latestItems = self.itemRelay.value
                
                if latestItems.contains(where: { $0.headerNumber == partyCount.number }) {
                    guard let index = latestItems.index(where: { current -> Bool in
                        return current.headerNumber == partyCount.number
                    }) else { return Observable.empty() }
                    
                    print("Index Section yang berubah = \(index)")
                }
                
                /// Match with current sections
                var currentParty = latestItems[partyCount.section]
                currentParty.headerCount = partyCount.value
    
                /// Assign latest values with current party
                latestItems[partyCount.section] = currentParty
                latestItems[partyCount.section].items = latestItems[partyCount.section].items
                
                self.itemRelay.accept(latestItems)
                return Observable.just(latestItems)
        }
        
        
        /// MARK
        /// Merge all Observable sections: It will contains 3 observable
        let mergeItems = Observable.merge(itemsSection, itemsUpdate, headerUpdates)
            .asDriverOnErrorJustComplete()
        
        
        
        /// TODO
        /// Get data realcount calculations saved
        /**
         initial value will triggered whenever view is appear
         - returns: candidates array and parties array, each
         candidates represent as Item Actor: have id, and total value
         we must store this id and value and match will some array of data in SectionModelDPR items
         **/
        let initialValue = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<RealCountResponse> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getCalculations(hitungRealCountId: self.realCount.id,
                                                             tingkat: self.type),
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
        let updateItems = counterS
//            .distinctUntilChanged({ $0.totalVote != $1.totalVote })
            .flatMapLatest { [weak self] (candidateCount) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                var currentCandidatesParty = self.candidatesPartyValue.value
                currentCandidatesParty.append(candidateCount)
                self.candidatesPartyValue.accept(currentCandidatesParty)
                self.updateSectionModel(candidatePartyCount: candidateCount)
                
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
        
//        let partyCount = counterPartyS
//            .flatMapLatest({ [weak self] (party) -> Observable<PartyCount> in
//                guard let `self` = self else { return Observable.empty() }
//                print(party)
//                return Observable.just(party)
//            })
//            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back,
                        itemsO: itemsRelay.asDriverOnErrorJustComplete(),
                        nameDapilO: nameDapil,
                        errorO: errorTracker.asDriver(),
                        invalidO: invalid,
                        initialValueO: initialValue,
                        dataO: data,
                        updateItemsO: updateItems,
                        itemsSections: mergeItems,
                        bufferPartyO: bufferPartyS.asDriverOnErrorJustComplete())
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
    /// MARK: - Transform response into section model
    /// this function will plot every section parties, and every section parties have candidates items
    /// match this values with Item actor and changes items in section model 
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
    
    private func updateSectionModel(candidatePartyCount: CandidatePartyCount) {
        var currentSectionedModels = self.itemsRelay.value
        
        var currentCandidate = currentSectionedModels[candidatePartyCount.indexPath.section]
        guard let index = currentCandidate.items.index(where: { current -> Bool in
            return current.id == candidatePartyCount.id
        }) else { return }
        
        var updateCandidate = currentCandidate.items.filter { (candidate) -> Bool in
            return candidate.id == candidatePartyCount.id
        }.first
        
        print("Index updated: \(index)")
        print("Updated candidate: \(updateCandidate)")
        
        if updateCandidate != nil {
            updateCandidate?.value = candidatePartyCount.totalVote
            currentCandidate.items[index] = updateCandidate!
            currentSectionedModels[candidatePartyCount.indexPath.section] = currentCandidate
            
            self.itemsRelay.accept(currentSectionedModels)
        }
    }

    
    /// Mark: - Generate candidates Actor
    private func generateCandidates(data: CandidateResponse, itemActor: [CandidatePartyCount]) -> [CandidateActor] {
        var candidate: [CandidateActor] = []
        print("Item actor: \(itemActor)")
        
        for datas in data.candidates ?? [] {
            let updatedValue = itemActor.filter({ $0.id == datas.id }).first?.totalVote
            candidate.append(CandidateActor(id: datas.id,
                                            name: datas.name ?? "",
                                            value: updatedValue ?? 0))
        }
        
        return candidate
    }
    
    
    /// MARK: - Transform response into SectionModelsCalculations
    private func transformToSectionsCalculations(response: [CandidateResponse]) -> Observable<[SectionModelCalculations]> {
        var items: [SectionModelCalculations] = []
        
        for item in response {
            let updatedSection = self.partyValue.value.filter({ $0.number == item.serialNumber }).first?.value
            items.append(SectionModelCalculations(header: item.name,
                                                  headerCount: updatedSection ?? 0,
                                                  headerNumber: item.serialNumber,
                                                  headerLogo: item.logo?.thumbnail.url ?? "",
                                                  items: self.generateCandidates(data: item, itemActor: self.candidatesPartyValue.value),
                                                  footerCount: 0))
        }
        
        self.itemRelay.accept(items)
        return Observable.just(items)
    }
    
    
}
