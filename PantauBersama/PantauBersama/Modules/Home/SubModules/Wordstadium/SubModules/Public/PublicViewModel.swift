//
//  PublicViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class PublicViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshTrigger: AnyObserver<String>
    }
    
    struct Output {
        let bannerInfo: Driver<BannerInfo>
        let infoSelected: Driver<Void>
        let showHeader: Driver<Bool>
    }
    
    private let refreshSubject = PublishSubject<String>()
    
    private let navigator: WordstadiumNavigator
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()

    init(navigator: WordstadiumNavigator, showTableHeader: Bool) {
        self.navigator = navigator
        
        input = Input(
            refreshTrigger: refreshSubject.asObserver())
        
        
        let bannerInfo = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        let showTableHeader = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        output = Output(bannerInfo: bannerInfo,
                        infoSelected: infoSelected,
                        showHeader: showTableHeader)
        
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "debat"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
