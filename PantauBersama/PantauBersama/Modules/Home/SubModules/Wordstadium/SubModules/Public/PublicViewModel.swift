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
        let items: Driver<[SectionWordstadium]>
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
        
        
        let showItems = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.generateWordstadium() })
            .asDriverOnErrorJustComplete()
        
        output = Output(bannerInfo: bannerInfo,
                        infoSelected: infoSelected,
                        showHeader: showTableHeader,
                        items: showItems)
        
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
    
    private func generateWordstadium() ->  Observable<[SectionWordstadium]> {
        var items : [SectionWordstadium] = []
        let live = SectionWordstadium(title: "",
                                       descriptiom: "",
                                       itemType: .live,
                                       items: [Wordstadium(title: "")],
                                       itemsLive: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")])
        
        let debat = SectionWordstadium(title: "LINIMASA DEBAT",
                                       descriptiom: "Daftar challenge dan debat yang akan atau sudah berlangsung ditampilkan semua di sini.",
                                       itemType: .comingsoon,
                                       items: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")],
                                       itemsLive: [])
        
        let done = SectionWordstadium(title: "Debat: Done",
                                       descriptiom: "",
                                       itemType: .done,
                                       items: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")],
                                       itemsLive: [])
        
        let chalenge = SectionWordstadium(title: "Challenge",
                                       descriptiom: "",
                                       itemType: .challenge,
                                       items: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")],
                                       itemsLive: [])
    
        items.append(live)
        items.append(debat)
        items.append(done)
        items.append(chalenge)
        
        return Observable.just(items)
    }
    
}
