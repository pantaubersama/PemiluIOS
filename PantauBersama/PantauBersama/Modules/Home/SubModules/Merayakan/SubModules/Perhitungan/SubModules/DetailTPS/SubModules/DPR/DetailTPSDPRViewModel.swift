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

class DetailTPSDPRViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let refreshI: AnyObserver<String>
    }
    
    struct Output {
        let backO: Driver<Void>
        let itemsO: Driver<[SectionModelDPR]>
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
    
    init(navigator: DetailTPSDPRNavigator, realCount: RealCount) {
        self.navigator = navigator
        self.realCount = realCount
        
        input = Input(backI: backS.asObserver(),
                      refreshI: refreshS.asObserver())
        
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
                    .do(onSuccess: { (response) in
                        print("Dapil response: \(response)")
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
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        output = Output(backO: back,
                        itemsO: items)
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
            items.append(SectionModelDPR(header: item.name , number: item.serialNumber, logo: item.logo?.thumbnail.url ?? "", items: item.candidates ?? []))
        }
        
        return Observable.just(items)
    }
}

final class TPSInfoDummyData {
    static func tpsInfoData(data: Candidates, header: String, number: Int, logo: String) -> Observable<[SectionModelDPR]> {
        
        var item: [SectionModelDPR] = []
        item.append(SectionModelDPR(header: header, number: number, logo: logo, items: [data]))
        return Observable.just(item)
        
    }
}
