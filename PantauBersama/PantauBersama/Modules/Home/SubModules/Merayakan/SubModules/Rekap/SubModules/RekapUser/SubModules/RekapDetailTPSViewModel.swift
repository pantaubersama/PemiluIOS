//
//  RekapDetailTPSViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import RxDataSources

final class RekapDetailTPSViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshI: AnyObserver<String>
        let backI: AnyObserver<Void>
    }
    
    struct Output {
        let itemsO: Driver<[SectionModelsTPSSummary]>
        let backO: Driver<Void>
    }
    
    private let navigator: RekapDetailTPSNavigator
    private let realCount: RealCount
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let refreshS = PublishSubject<String>()
    private let backS = PublishSubject<Void>()
    
    
    init(navigator: RekapDetailTPSNavigator, realCount: RealCount) {
        self.navigator = navigator
        self.realCount = realCount
        
        input = Input(refreshI: refreshS.asObserver(), backI: backS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        /// GET Summary presiden
        let summaryPresiden = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<DetailSummaryPercentage> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.summaryPresidenShow(level: 6, region: realCount.villageCode, tps: realCount.tps, realCountId: realCount.id), c: BaseResponse<DetailSummaryPresidenResponse>.self)
                    .map({ $0.data.percentage })
                    .do(onSuccess: { (summary) in
                        print("Summary: \(summary)")
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
            }
        
        
        /// Get Detail C1 Presiden
        let c1Summary = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<C1Response> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.getFormC1(hitungRealCountId: realCount.id, tingkat: .presiden), c: BaseResponse<SummaryC1Response>.self)
                    .map({ $0.data.formC1 })
                    .do(onSuccess: { (summary) in
                        print("Summary: \(summary)")
                    }, onError: { (e) in
                        print(e.localizedDescription)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                
        }
        
        /// Assing to items section
        let item = Observable.combineLatest(summaryPresiden, c1Summary)
            .flatMapLatest { (summaryPresiden, c1Summary) -> Observable<[SectionModelsTPSSummary]> in
                return Observable.just([
                    SectionModelsTPSSummary(title: nil, description: nil, items: [TPSItemModel.presiden(summaryPresiden)]),
                    SectionModelsTPSSummary(title: nil, description: "Lampiran", items: [TPSItemModel.lampiran(c1Summary.realCount.logs)]),
                    SectionModelsTPSSummary(title: "I. DATA PEMILIH dan DATA PENGGUNA HAK PILIH", description: "A. DATA PEMILIH", items: [
                            TPSItemModel.c1PemilihDPT(c1Summary),
                            TPSItemModel.c1PemilihDPTb(c1Summary),
                            TPSItemModel.c1PemilihDPK(c1Summary),
                            TPSItemModel.c1TotalPemilihA1A3(c1Summary)
                        ]),
                    SectionModelsTPSSummary(title: nil, description: "B. PENGGUNA HAK PILIH", items: [
                            TPSItemModel.c1HakDPT(c1Summary),
                            TPSItemModel.c1HakDPTb(c1Summary),
                            TPSItemModel.c1HakDPK(c1Summary),
                            TPSItemModel.c1TotalHakB1B3(c1Summary)
                        ]),
                    SectionModelsTPSSummary(title: "II. DATA PEMILIH DISABILITAS", description: nil, items: [
                            TPSItemModel.c1DisabilitasTotal(c1Summary),
                            TPSItemModel.c1DisabilitasHak(c1Summary)
                        ]),
                    SectionModelsTPSSummary(title: "III. DATA PENGGUNAAN SURAT SUARA", description: nil, items: [
                            TPSItemModel.c1TotalSuaraDPT(c1Summary),
                            TPSItemModel.c1TotalSuraRusak(c1Summary),
                            TPSItemModel.c1TotalSuaraTidakDigunakan(c1Summary),
                            TPSItemModel.c1TotalSuaraDigunakan(c1Summary)
                        ])
                ])
        }.asDriver(onErrorJustReturn: [])
        
        
        output = Output(itemsO: item, backO: back)
        
    }
}

enum TPSItemModel {
    case presiden(DetailSummaryPercentage)
    case lampiran(Logs?)
    case c1PemilihDPT(C1Response)
    case c1PemilihDPTb(C1Response)
    case c1PemilihDPK(C1Response)
    case c1TotalPemilihA1A3(C1Response)
    case c1HakDPT(C1Response)
    case c1HakDPTb(C1Response)
    case c1HakDPK(C1Response)
    case c1TotalHakB1B3(C1Response)
    case c1DisabilitasTotal(C1Response)
    case c1DisabilitasHak(C1Response)
    case c1TotalSuaraDPT(C1Response)
    case c1TotalSuraRusak(C1Response)
    case c1TotalSuaraTidakDigunakan(C1Response)
    case c1TotalSuaraDigunakan(C1Response)
}

struct SectionModelsTPSSummary {
    let title: String?
    let description: String?
    var items: [TPSItemModel]
    
    init(title: String?, description: String?, items: [TPSItemModel]) {
        self.title = title
        self.description = description
        self.items = items
    }
}

extension SectionModelsTPSSummary: SectionModelType {
    typealias Item = TPSItemModel
    
    init(original: SectionModelsTPSSummary, items: [TPSItemModel]) {
        self = original
        self.items = items
    }
}
