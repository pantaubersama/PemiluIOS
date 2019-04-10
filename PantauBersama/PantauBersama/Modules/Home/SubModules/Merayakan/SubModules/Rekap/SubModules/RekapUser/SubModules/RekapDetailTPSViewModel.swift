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
        let nextI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let summaryPresidenO: Driver<DetailSummaryPresidenResponse>
        let c1SummaryO: Driver<C1Response>
        let errorO: Driver<Error>
        let itemsImageO: Driver<[SectionModelsTPSImages]>
    }
    
    private let navigator: RekapDetailTPSNavigator
    private let realCount: RealCount
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    private let refreshS = PublishSubject<String>()
    private let backS = PublishSubject<Void>()
    private let nextS = PublishSubject<Void>()
    
    var presidenImage = BehaviorRelay<[ImageResponse]>(value: [])
    var suasanaImage = BehaviorRelay<[ImageResponse]>(value: [])
    
    init(navigator: RekapDetailTPSNavigator, realCount: RealCount) {
        self.navigator = navigator
        self.realCount = realCount
        
        input = Input(refreshI: refreshS.asObserver(),
                      backI: backS.asObserver(),
                      nextI: nextS.asObserver())
        
        let back = backS
            .flatMapLatest({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        
        /// GET Summary presiden
        let summaryPresiden = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<DetailSummaryPresidenResponse> in
                guard let `self` = self else { return Observable.empty() }
                return NetworkService.instance
                    .requestObject(HitungAPI.summaryPresidenShow(level: 6, region: realCount.villageCode, tps: realCount.tps, realCountId: realCount.id), c: BaseResponse<DetailSummaryPresidenResponse>.self)
                    .map({ $0.data })
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
        
        /// Get Section Images
        let itemImages = refreshS.startWith("")
            .flatMapLatest { [weak self] (_) -> Observable<[SectionModelsTPSImages]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1Presiden)
                    .map({ [weak self] (data) -> [SectionModelsTPSImages] in
                        guard let `self` = self else { return [] }
                        return self.transformToSection(data: data, type: .c1Presiden)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionModelsTPSImages]> in
                guard let `self` = self else { return Observable.empty()
                }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPR)
                    .map({ [weak self] (data) -> [SectionModelsTPSImages] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPR)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionModelsTPSImages]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPD)
                    .map({ [weak self] (data) -> [SectionModelsTPSImages] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPD)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionModelsTPSImages]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPRDProvinsi)
                    .map({ [weak self] (data) -> [SectionModelsTPSImages] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPRDProvinsi)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionModelsTPSImages]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .c1DPRDKabupaten)
                    .map({ [weak self] (data) -> [SectionModelsTPSImages] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .c1DPRDKabupaten)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }
            .flatMapLatest { [weak self] (section) -> Observable<[SectionModelsTPSImages]> in
                guard let `self` = self else { return Observable.empty() }
                return self.paginateItems(nextBatchTrigger: self.nextS.asObservable(), type: .suasanaTPS)
                    .map({ [weak self] (data) -> [SectionModelsTPSImages] in
                        guard let `self` = self else { return [] }
                        return section + self.transformToSection(data: data, type: .suasanaTPS)
                    })
                    .trackActivity(self.activityIndicator)
                    .trackError(self.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            }.asDriver(onErrorJustReturn: [])
        
        
        
        output = Output(backO: back,
                        summaryPresidenO: summaryPresiden.asDriverOnErrorJustComplete(),
                        c1SummaryO: c1Summary.asDriverOnErrorJustComplete(),
                        errorO: errorTracker.asDriver(),
                        itemsImageO: itemImages)
        
    }
    
    
    private func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>,
        type: RealCountImageType) -> Observable<[ImageResponse]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, type: type)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    private func recursivelyPaginateItems(
        batch: Batch,
        nextBatchTrigger: Observable<Void>,
        type: RealCountImageType) -> Observable<Page<[ImageResponse]>> {
        return NetworkService.instance
            .requestObject(HitungAPI
                .getImagesRealCount(hitungRealCountId: realCount.id,
                                    type: type,
                                    page: batch.page,
                                    perPage: batch.offset),
                           c: BaseResponse<SummaryImageResponse>.self)
            .map({ self.transformToPage(response: $0, batch: batch)})
            .asObservable()
            .paginate(nextPageTrigger: nextBatchTrigger, hasNextPage: { (result) -> Bool in
                return result.batch.next().hasNextPage
            }, nextPageFactory: { (result) -> Observable<Page<[ImageResponse]>> in
                self.recursivelyPaginateItems(batch: result.batch.next(), nextBatchTrigger: nextBatchTrigger, type: type)
            })
    }
    
    private func transformToPage(response: BaseResponse<SummaryImageResponse>, batch: Batch) -> Page<[ImageResponse]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ?? 10,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[ImageResponse]>(
            item: response.data.image,
            batch: nextBatch
        )
    }
    
    private func transformToSection(data: [ImageResponse], type: RealCountImageType) -> [SectionModelsTPSImages] {
        
        var title: String = ""
        
        switch type {
        case .c1Presiden:
            if data.count == 0 {
                title = ""
            } else {
                title = "Lampiran Model C1-PPWP (Presiden)"
            }
        case .c1DPR:
            if data.count == 0 {
                title = ""
            } else {
                title = "Lampiran Model C1-DPR RI"
            }
        case .c1DPD:
            if data.count == 0 {
                title = ""
            } else {
                title = "Lampiran Model C1-DPD"
            }
        case .c1DPRDProvinsi:
            if data.count == 0 {
                title = ""
            } else {
                title = "Lampiran Model C1-DPRD Provinsi"
            }
        case .c1DPRDKabupaten:
            if data.count == 0 {
                title = ""
            } else {
                title = "Lampiran Model C1-DPRD Kabupaten/Kota"
            }
        case .suasanaTPS:
            if data.count == 0 {
                title = ""
            } else {
                title = "Lampiran Suasana TPS"
            }
        }
        return [SectionModelsTPSImages(title: title, items: data)]
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


struct SectionModelsTPSImages {
    let title: String
    var items: [ImageResponse]
    
    init(title: String, items: [ImageResponse]) {
        self.title = title
        self.items = items
    }
}

extension SectionModelsTPSImages: SectionModelType {
    typealias Item = ImageResponse
    
    init(original: SectionModelsTPSImages, items: [ImageResponse]) {
        self = original
        self.items = items
    }
}
