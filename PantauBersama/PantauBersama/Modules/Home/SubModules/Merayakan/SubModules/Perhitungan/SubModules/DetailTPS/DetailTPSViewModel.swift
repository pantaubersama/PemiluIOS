//
//  DetailTPSViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class DetailTPSViewModel: ViewModelType {
    struct Input {
        let backI: AnyObserver<Void>
        let moreI: AnyObserver<RealCount>
        let moreMenuI: AnyObserver<PerhitunganType>
        let sendDataActionI: AnyObserver<Void>
        let submitActionI: AnyObserver<Void>
        let successSubmitI: AnyObserver<Void>
        let detailPresidenI: AnyObserver<Void>
        let detailDPRI: AnyObserver<Void>
        let detailDPDI: AnyObserver<Void>
        let detailDPRProvI: AnyObserver<Void>
        let detailDPRKotaI: AnyObserver<Void>
        let c1UploadI: AnyObserver<Void>
        let c1PresidenI: AnyObserver<Void>
        let c1DPRI: AnyObserver<Void>
        let c1DPDI: AnyObserver<Void>
        let c1DPRDProvI: AnyObserver<Void>
        let c1DPRDKotaI: AnyObserver<Void>
    }
    
    struct Output {
        let backO: Driver<Void>
        let moreO: Driver<RealCount>
        let moreMenuO: Driver<Void>
        let sendDataActionO: Driver<Void>
        let submitActionO: Driver<Void>
        let successSubmitO: Driver<Void>
        let detailPresidenO: Driver<Void>
        let detailDPRO: Driver<Void>
        let detailDPDO: Driver<Void>
        let detailDPRProvO: Driver<Void>
        let detailDPRKotaO: Driver<Void>
        let c1UploadO: Driver<Void>        
        let c1PresidenO: Driver<Void>
        let c1DPRO: Driver<Void>
        let c1DPDO: Driver<Void>
        let c1DPRDProvO: Driver<Void>
        let c1DPRDKotaO: Driver<Void>
        let realCountO: Driver<RealCount>
        let errorO: Driver<Error>
    }
    
    var input: Input
    var output: Output!
    
    private let navigator: DetailTPSNavigator
    private let data: RealCount
    
    private let moreS = PublishSubject<RealCount>()
    private let moreMenuS = PublishSubject<PerhitunganType>()
    private let successSubmitS = PublishSubject<Void>()
    private let sendDataActionS = PublishSubject<Void>()
    private let submitActionS = PublishSubject<Void>()
    private let backS = PublishSubject<Void>()
    private let detailPresidenS = PublishSubject<Void>()
    private let detailDPRS = PublishSubject<Void>()
    private let detailDPDS = PublishSubject<Void>()
    private let detailDPRProvS = PublishSubject<Void>()
    private let detailDPRKotaS = PublishSubject<Void>()
    private let c1PresidenS = PublishSubject<Void>()
    private let c1DPRS = PublishSubject<Void>()
    private let c1DPDS = PublishSubject<Void>()
    private let c1DPRDProvS = PublishSubject<Void>()
    private let c1DPRDKotaS = PublishSubject<Void>()
    private let c1UploadS = PublishSubject<Void>()
    
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    
    init(navigator: DetailTPSNavigator, realCount: RealCount) {
        self.navigator = navigator
        self.data = realCount
        
        input = Input(
            backI: backS.asObserver(),
            moreI: moreS.asObserver(),
            moreMenuI: moreMenuS.asObserver(),
            sendDataActionI: sendDataActionS.asObserver(),
            submitActionI: submitActionS.asObserver(),
            successSubmitI: successSubmitS.asObserver(),
            detailPresidenI: detailPresidenS.asObserver(),
            detailDPRI: detailDPRS.asObserver(),
            detailDPDI: detailDPDS.asObserver(),
            detailDPRProvI: detailDPRProvS.asObserver(),
            detailDPRKotaI: detailDPRKotaS.asObserver(),
            c1UploadI: c1UploadS.asObserver(),
            c1PresidenI: c1PresidenS.asObserver(),
            c1DPRI: c1DPRS.asObserver(),
            c1DPDI: c1DPRDProvS.asObserver(),
            c1DPRDProvI: c1DPRDProvS.asObserver(),
            c1DPRDKotaI: c1DPRDKotaS.asObserver()
        )
        
        let back = backS
            .flatMap({ navigator.back() })
            .asDriverOnErrorJustComplete()
        
        let sendDataAction = sendDataActionS
            .flatMap({ navigator.sendData() })
            .asDriverOnErrorJustComplete()
        
        let submitAction = submitActionS
            .flatMap({ (_) in
                return NetworkService.instance.requestObject(
                    HitungAPI.publishRealCount(id: realCount.id),
                    c: BaseResponse<CreateTpsResponse>.self)
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .catchErrorJustComplete()
            })
            .mapToVoid().asDriverOnErrorJustComplete()
        
        let successSubmit = successSubmitS
            .flatMap({ navigator.successSubmit() })
            .asDriverOnErrorJustComplete()
        
        let detailPresiden = detailPresidenS
            .flatMap({ navigator.launchDetailTPSPresiden(data: self.data) })
            .asDriverOnErrorJustComplete()
        
        let detailDPR = detailDPRS
            .flatMap({ navigator.launchDetailTPSDPRI(data: self.data) })
            .asDriverOnErrorJustComplete()
        
        let detailDPD = detailDPDS
            .flatMap({ navigator.launchDetailTPSDPD(data: self.data) })
            .asDriverOnErrorJustComplete()
        
        let detailDPRProv = detailDPRProvS
            .flatMap({ navigator.launchDetailTPSDPRDProv(data: self.data) })
            .asDriverOnErrorJustComplete()
        
        let detailDPRKota = detailDPRKotaS
            .flatMap({ navigator.launchDetailTPSDPRDKab(data: self.data) })
            .asDriverOnErrorJustComplete()
        
        let c1Upload = c1UploadS
            .flatMap({ navigator.launchUploadC1(data: self.data) })
            .asDriverOnErrorJustComplete()
        
        let c1FormPresiden = c1PresidenS
            .flatMap({ _ in navigator.launchC1Form(type: .presiden, data: self.data, tingkat: .presiden) })
            .asDriverOnErrorJustComplete()
        
        let c1FormDPR = c1DPRS
            .flatMap({ navigator.launchC1Form(type: .dpr, data: self.data, tingkat: .dpr) })
            .asDriverOnErrorJustComplete()
        
        let c1FormDPD = c1DPDS
            .flatMap({ navigator.launchC1Form(type: .dpd, data: self.data, tingkat: .dpd) })
            .asDriverOnErrorJustComplete()
        
        let c1FormDPRDProv = c1DPRDProvS
            .flatMap({ navigator.launchC1Form(type: .dprdProv, data: self.data, tingkat: .provinsi) })
            .asDriverOnErrorJustComplete()
        
        let c1FormDPRDKota = c1DPRDKotaS
            .flatMap({ navigator.launchC1Form(type: .dprdKota, data: self.data, tingkat: .kabupaten) })
            .asDriverOnErrorJustComplete()
        
        
        let moreSelected = moreS
            .asObserver().asDriverOnErrorJustComplete()
        
        let moreMenuSelected = moreMenuS
            .flatMapLatest({ (type) -> Observable<Void> in
                switch type {
                case .hapus(let data):
                    return self.deleteRealCount(id: data.id)
                        .flatMapLatest({ navigator.back() })
                case .edit(let data):
                    return self.navigator.launchEditTPS(realCount: data)
                }
                
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            backO: back,
            moreO: moreSelected,
            moreMenuO: moreMenuSelected,
            sendDataActionO: sendDataAction,
            submitActionO: submitAction,
            successSubmitO: successSubmit,
            detailPresidenO: detailPresiden,
            detailDPRO: detailDPR,
            detailDPDO: detailDPD,
            detailDPRProvO: detailDPRProv,
            detailDPRKotaO: detailDPRKota,
            c1UploadO: c1Upload,            
            c1PresidenO: c1FormPresiden,
            c1DPRO: c1FormDPR,
            c1DPDO: c1FormDPD,
            c1DPRDProvO: c1FormDPRDProv,
            c1DPRDKotaO: c1FormDPRDKota,
            realCountO: Driver.just(realCount),
            errorO: errorTracker.asDriver()
        )
        
        
       
    }
}

extension DetailTPSViewModel {
    /// MARK: Delete realcounts
    private func deleteRealCount(id: String) -> Observable<Void> {
        return NetworkService.instance
            .requestObject(HitungAPI.deleteRealCount(id: id),
                           c: BaseResponse<CreateTpsResponse>.self)
            .asObservable()
            .trackError(self.errorTracker)
            .trackActivity(self.activityIndicator)
            .mapToVoid()
    }
}
