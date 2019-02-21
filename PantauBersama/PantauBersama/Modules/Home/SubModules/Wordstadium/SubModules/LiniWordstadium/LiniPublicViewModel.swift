//
//  LiniPublicViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class LiniPublicViewModel: ILiniWordstadiumViewModel, ILiniWordstadiumViewModelInput, ILiniWordstadiumViewModelOutput {
    var input: ILiniWordstadiumViewModelInput { return self }
    var output: ILiniWordstadiumViewModelOutput { return self }
    
    var refreshI: AnyObserver<String>
    var moreI: AnyObserver<Wordstadium>
    var moreMenuI: AnyObserver<WordstadiumType>
    var seeMoreI: AnyObserver<SectionWordstadium>
    var itemSelectedI: AnyObserver<Wordstadium>
    
    var bannerO: Driver<BannerInfo>!
    var itemSelectedO: Driver<Void>!
    var showHeaderO: Driver<Bool>!
    var itemsO: Driver<[SectionWordstadium]>!
    var moreSelectedO: Driver<Wordstadium>!
    var moreMenuSelectedO: Driver<String>!
    
    private let refreshSubject = PublishSubject<String>()
    private let moreSubject = PublishSubject<Wordstadium>()
    private let moreMenuSubject = PublishSubject<WordstadiumType>()
    private let seeMoreSubject = PublishSubject<SectionWordstadium>()
    private let itemSelectedSubject = PublishSubject<Wordstadium>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: WordstadiumNavigator, showTableHeader: Bool) {
        refreshI = refreshSubject.asObserver()
        moreI = moreSubject.asObserver()
        moreMenuI = moreMenuSubject.asObserver()
        seeMoreI = seeMoreSubject.asObserver()
        itemSelectedI = itemSelectedSubject.asObserver()
        
        bannerO = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.bannerInfo() })
            .asDriverOnErrorJustComplete()
        
        showHeaderO = BehaviorRelay<Bool>(value: showTableHeader).asDriver()
        
        let infoSelected = headerViewModel.output.itemSelected
            .asObservable()
            .flatMapLatest({ (banner) -> Observable<Void> in
                return navigator.launchBannerInfo(bannerInfo: banner)
            })
            .asDriverOnErrorJustComplete()
        
        let seeMoreSelected = seeMoreSubject
            .asObservable()
            .flatMapLatest({ (wordstadium) -> Observable<Void> in
                return navigator.launchWordstadiumList(wordstadium: wordstadium)
            })
            .asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedSubject
            .asObservable()
            .flatMapLatest({ (wordstadium) -> Observable<Void> in
                return navigator.launchLiveChallenge(wordstadium: wordstadium)
            })
            .asDriverOnErrorJustComplete()
        
        itemSelectedO = Driver.merge(infoSelected,seeMoreSelected,itemSelected)
        
        itemsO = refreshSubject.startWith("")
            .flatMapLatest({ _ in self.generateWordstadium() })
            .asDriverOnErrorJustComplete()
        
        moreSelectedO = moreSubject
            .asObservable()
            .asDriverOnErrorJustComplete()
        
        moreMenuSelectedO = moreMenuSubject
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .bagikan(let data):
                    return Observable.just("Tautan telah dibagikan")
                case .salin(let data):
                    return Observable.just("Tautan telah tersalin")
                default:
                    return Observable.empty()
                }
            }
            .asDriverOnErrorJustComplete()
        
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
                                      items: [Wordstadium(title: "", type: .default)],
                                      itemsLive: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)])
        
        let debat = SectionWordstadium(title: "LINIMASA DEBAT",
                                       descriptiom: "Daftar challenge dan debat yang akan atau sudah berlangsung ditampilkan semua di sini.",
                                       itemType: .comingsoon,
                                       items: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)],
                                       itemsLive: [])
        
        let done = SectionWordstadium(title: "Debat: Done",
                                      descriptiom: "",
                                      itemType: .done,
                                      items: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)],
                                      itemsLive: [])
        
        let chalenge = SectionWordstadium(title: "Challenge",
                                          descriptiom: "",
                                          itemType: .challenge,
                                          items: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)],
                                          itemsLive: [])
        
        items.append(live)
        items.append(debat)
        items.append(done)
        items.append(chalenge)
        
        return Observable.just(items)
    }
    
}
