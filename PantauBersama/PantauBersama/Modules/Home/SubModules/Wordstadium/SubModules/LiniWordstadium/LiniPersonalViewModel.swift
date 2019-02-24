//
//  LiniPersonalViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

class LiniPersonalViewModel: ILiniWordstadiumViewModel, ILiniWordstadiumViewModelInput, ILiniWordstadiumViewModelOutput {
    var input: ILiniWordstadiumViewModelInput { return self }
    var output: ILiniWordstadiumViewModelOutput { return self }
    
    var refreshI: AnyObserver<Void>
    var moreI: AnyObserver<Wordstadium>
    var moreMenuI: AnyObserver<WordstadiumType>
    var seeMoreI: AnyObserver<SectionWordstadium>
    var itemSelectedI: AnyObserver<Wordstadium>
    
    var bannerO: Driver<BannerInfo>!
    var itemSelectedO: Driver<Void>!
    var showHeaderO: Driver<Bool>!
    var itemsO: Driver<[SectionChallenge]>!
    var moreSelectedO: Driver<Wordstadium>!
    var moreMenuSelectedO: Driver<String>!
    var isLoading: Driver<Bool>!
    var error: Driver<Error>!
    var items: Driver<[Challenge]>!
    
    private let refreshSubject = PublishSubject<Void>()
    private let moreSubject = PublishSubject<Wordstadium>()
    private let moreMenuSubject = PublishSubject<WordstadiumType>()
    private let seeMoreSubject = PublishSubject<SectionWordstadium>()
    private let itemSelectedSubject = PublishSubject<Wordstadium>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
    private let challengeItems = BehaviorRelay<[Challenge]>(value: [])
    
    init(navigator: WordstadiumNavigator, showTableHeader: Bool) {
        refreshI = refreshSubject.asObserver()
        moreI = moreSubject.asObserver()
        moreMenuI = moreMenuSubject.asObserver()
        seeMoreI = seeMoreSubject.asObserver()
        itemSelectedI = itemSelectedSubject.asObserver()
        
        error = errorTracker.asDriver()
        isLoading = activityIndicator.asDriver()
        
        bannerO = refreshSubject.startWith(())
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
        
//        itemsO = refreshSubject.startWith(())
//            .flatMapLatest({ _ in self.generateWordstadium() })
//            .asDriverOnErrorJustComplete()
        
        let liveItems = refreshSubject
            .startWith(())
            .flatMapLatest({ [weak self] (_) -> Observable<[Challenge]> in
                guard let `self` = self else { return Observable<[Challenge]>.just([]) }
                return self.getChallenge(progress: .liveNow)
            }).asDriver(onErrorJustReturn: [])
        
        let comingSoonItems = refreshSubject
            .startWith(())
            .flatMapLatest({ [weak self] (_) -> Observable<[Challenge]> in
                guard let `self` = self else { return Observable<[Challenge]>.just([]) }
                return self.getChallenge(progress: .comingSoon)
            }).asDriver(onErrorJustReturn: [])
        
        let doneItems = refreshSubject
            .startWith(())
            .flatMapLatest({ [weak self] (_) -> Observable<[Challenge]> in
                guard let `self` = self else { return Observable<[Challenge]>.just([]) }
                return self.getChallenge(progress: .done)
            }).asDriver(onErrorJustReturn: [])
        
        let onGoingItems = refreshSubject
            .startWith(())
            .flatMapLatest({ [weak self] (_) -> Observable<[Challenge]> in
                guard let `self` = self else { return Observable<[Challenge]>.just([]) }
                return self.getChallenge(progress: .ongoing)
            }).asDriver(onErrorJustReturn: [])
        
        itemsO = Driver.empty()
        
//        items = Driver.combineLatest(liveItems,comingSoonItems,doneItems,onGoingItems)
//            .map({ (live,comingsoon,done,ongoing) -> [Challenge] in
//                return live + comingsoon + done + ongoing
//            })
        
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
                                      items: [Wordstadium(title: "", type: .default)],
                                      itemsLive: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)])
        
        let debat = SectionWordstadium(title: "MY WORDSTADIUM",
                                       descriptiom: "Daftar tantangan dan debat yang akan atau sudah kamu ikuti ditampilkan semua di sini.",
                                       itemType: .comingsoon,
                                       items: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)],
                                       itemsLive: [])
        
        let done = SectionWordstadium(title: "My Debat: Done",
                                      descriptiom: "",
                                      itemType: .done,
                                      items: [Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge),Wordstadium(title: "", type: .challenge)],
                                      itemsLive: [])
        
        let chalenge = SectionWordstadium(title: "My Challenge",
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
    
    func getChallenge(progress: ProgressType) -> Observable<[Challenge]>{
        return NetworkService.instance
            .requestObject(WordstadiumAPI.getPublicChallenges(type: progress),
                           c: BaseResponse<GetChallengeResponse>.self)
            .map{( $0.data.challenges )}
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
    }
    
//    func recursivelyPaginateItems(batch: BatchChallenge, progress: ProgressType) -> Observable<ChallengePage<[Challenge]>> {
//        return NetworkService.instance
//            .requestObject(WordstadiumAPI.getPersonalChallenges(type: progress),
//                           c: BaseResponse<GetChallengeResponse>.self)
//            .map{( self.transformToPage(response: $0, batch: batch) )}
//            .asObservable()
//
//    }
    
    
}
