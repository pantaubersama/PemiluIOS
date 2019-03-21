//
//  PerhitunganViewModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class PerhitunganViewModel: ViewModelType {
    struct Input {
        let refreshTrigger: AnyObserver<Void>
        let createPerhitunganI: AnyObserver<Void>
    }
    
    struct Output {
        let createPerhitunganO: Driver<Void>
        let bannerInfo: Driver<BannerInfo>
        let infoSelected: Driver<Void>
    }
    
    var input: Input
    var output: Output!
    private let navigator: PerhitunganNavigator
    let headerViewModel = BannerHeaderViewModel()
    
    private let refreshSubject = PublishSubject<Void>()
    private let createPerhitunganS = PublishSubject<Void>()
    
    init(navigator: PerhitunganNavigator) {
        self.navigator = navigator
        
        input = Input(refreshTrigger: refreshSubject.asObserver(),
                      createPerhitunganI: createPerhitunganS.asObserver())
        
        let createPerhitungan = createPerhitunganS
            .flatMap({ navigator.launchCreatePerhitungan() })
            .asDriverOnErrorJustComplete()
        
        let bannerInfo = refreshSubject.startWith(())
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        output = Output(createPerhitunganO: createPerhitungan,
                        bannerInfo: bannerInfo,
                        infoSelected: infoSelected)
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: BannerPage.perhitungan ),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
}



