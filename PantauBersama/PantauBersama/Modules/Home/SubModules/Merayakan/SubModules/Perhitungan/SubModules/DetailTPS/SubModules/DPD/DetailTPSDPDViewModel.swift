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
    }
    
    struct Output {
        let backO: Driver<Void>
        let items: Driver<[SectionModelDPD]>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSDPDNavigator
    private let data: RealCount
    private let tingkat: TingkatPemilihan
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let refreshS = PublishSubject<String>()
    
    var nameWilayahRelay = BehaviorRelay<String>(value: "")
    
    private let backS = PublishSubject<Void>()
    private let detailTPSS = PublishSubject<Void>()
    
    init(navigator: DetailTPSDPDNavigator, data: RealCount, tingkat: TingkatPemilihan) {
        self.navigator = navigator
        self.data = data
        self.tingkat = tingkat
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver())
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        /// TODO
        /// GET Section All Dapil and Candidates
        let data = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[CandidateDPDResponse]> in
                guard let `self` = self else { return Observable.empty() }
                return self.getDapils(tingkat: self.tingkat)
            }
            .flatMapLatest { [weak self] (response) -> Observable<[SectionModelDPD]> in
                guard let `self` = self else { return Observable.empty() }
                return self.transformToSection(response: response)
            }
            .asDriverOnErrorJustComplete()
        
        
        
        output = Output(backO: back,
                        items: data)
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
            .do(onSuccess: { [weak self] (response) in
                guard let `self` = self else { return }
                let nameWilayah = response.first?.nama ?? ""
                self.nameWilayahRelay.accept(nameWilayah)
            })
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .asObservable()
    }
    /// MARK: - Transform to Sections
    private func transformToSection(response: [CandidateDPDResponse]) -> Observable<[SectionModelDPD]> {
        var items: [SectionModelDPD] = []
        for item in response {
            self.nameWilayahRelay.accept(item.nama)
            items.append(SectionModelDPD(header: item.nama,
                                         items: self.generateCandidates(data: item)))
        }
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
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
    
}

extension SectionModelDPD: SectionModelType {
    typealias Item = CandidateActor
    
    init(original: SectionModelDPD, items: [CandidateActor]) {
        self = original
        self.items = items
    }
}
