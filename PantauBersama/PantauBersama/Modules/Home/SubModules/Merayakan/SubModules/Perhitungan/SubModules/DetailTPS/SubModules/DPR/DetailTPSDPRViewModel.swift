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
            .distinctUntilChanged({ $0.totalVote != $1.totalVote })
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
}


struct SectionCandidateTableViewState {
    
    var sections: [SectionModelDPR]
    
    init(section: [SectionModelDPR]) {
        self.sections = section
    }
    
    func executeCommand(command: CandidateTableViewCommand) -> SectionCandidateTableViewState {
        switch command {
        case .updateItem(let data):
            var sections = self.sections
            let items = sections[data.section].items
            
            sections[data.section] = SectionModelDPR(original: sections[data.section], items: items)
            
            return SectionCandidateTableViewState(section: sections)
        }
    }
}


enum CandidateTableViewCommand {
    case updateItem(item: CandidateActor, section: Int, header: Int, footer: Int)
}


