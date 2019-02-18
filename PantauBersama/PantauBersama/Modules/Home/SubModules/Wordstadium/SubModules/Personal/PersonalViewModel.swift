//
//  PersonalViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class PersonalViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let refreshTrigger: AnyObserver<String>
    }
    
    struct Output {
        let bannerInfo: Driver<BannerInfo>
        let itemSelected: Driver<Void>
        let showHeader: Driver<Bool>
        let items: Driver<[SectionWordstadium]>
    }
    
    private let refreshSubject = PublishSubject<String>()
    
    private let navigator: WordstadiumNavigator
    let errorTracker = ErrorTracker()
    let activityIndicator = ActivityIndicator()
    let headerViewModel = BannerHeaderViewModel()
    let seeMoreViewModel = SeeMoreViewModel()
    let collectionViewModel = WordstadiumCellViewModel()
    
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
        
        let seeMoreSelected = seeMoreViewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ (wordstadium) -> Observable<Void> in
                return navigator.launchWordstadiumList(wordstadium: wordstadium)
            })
            .asDriverOnErrorJustComplete()
        
        let seeMoreColSelected = collectionViewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ (wordstadium) -> Observable<Void> in
                return navigator.launchWordstadiumList(wordstadium: wordstadium)
            })
            .asDriverOnErrorJustComplete()
        
        let itemColSelected = collectionViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (wordstadium) -> Observable<Void> in
                return navigator.launchChallenge(wordstadium: wordstadium)
            })
            .asDriverOnErrorJustComplete()
        
        let itemSelected = Driver.merge(infoSelected,seeMoreSelected,seeMoreColSelected,itemColSelected)
        
        output = Output(bannerInfo: bannerInfo,
                        itemSelected: itemSelected,
                        showHeader: showTableHeader,
                        items: showItems)
        
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "tantangan"),
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
                                      itemType: .inProgress,
                                      items: [Wordstadium(title: "")],
                                      itemsLive: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")])
        
        let debat = SectionWordstadium(title: "MY WORDSTADIUM",
                                       descriptiom: "Daftar tantangan dan debat yang akan atau sudah kamu ikuti ditampilkan semua di sini.",
                                       itemType: .comingsoon,
                                       items: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")],
                                       itemsLive: [])
        
        let done = SectionWordstadium(title: "My Debat: Done",
                                      descriptiom: "",
                                      itemType: .done,
                                      items: [Wordstadium(title: ""),Wordstadium(title: ""),Wordstadium(title: "")],
                                      itemsLive: [])
        
        let chalenge = SectionWordstadium(title: "My Challenge",
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
