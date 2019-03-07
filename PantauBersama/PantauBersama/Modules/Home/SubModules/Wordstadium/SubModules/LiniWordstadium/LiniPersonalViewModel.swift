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
    var moreI: AnyObserver<Challenge>
    var moreMenuI: AnyObserver<WordstadiumType>
    var seeMoreI: AnyObserver<SectionWordstadium>
    var itemSelectedI: AnyObserver<Challenge>
    
    var bannerO: Driver<BannerInfo>!
    var itemSelectedO: Driver<Void>!
    var showHeaderO: Driver<Bool>!
    var itemsO: Driver<[SectionWordstadium]>!
    var moreSelectedO: Driver<Challenge>!
    var moreMenuSelectedO: Driver<String>!
    var isLoading: Driver<Bool>!
    var error: Driver<Error>!
    
    private let refreshSubject = PublishSubject<Void>()
    private let moreSubject = PublishSubject<Challenge>()
    private let moreMenuSubject = PublishSubject<WordstadiumType>()
    private let seeMoreSubject = PublishSubject<SectionWordstadium>()
    private let itemSelectedSubject = PublishSubject<Challenge>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
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
                if wordstadium.progress == .liveNow {
                    return navigator.launchLiveChallenge(wordstadium: wordstadium)
                } else {
                    return navigator.launchChallenge(wordstadium: wordstadium)
                }
            })
            .asDriverOnErrorJustComplete()
        
        itemSelectedO = Driver.merge(infoSelected,seeMoreSelected,itemSelected)
        
        // MARK:
        // Get challenge list
        itemsO = refreshSubject.startWith(())
            .flatMapLatest({ [weak self](_) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .liveNow, type: .personal)
                    .map { [weak self](items) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        if items.isEmpty {
                            return []
                        } else {
                            return  weakSelf.transformToSection(challenge: items, progress: .liveNow, type: .personal)
                        }
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](challenge) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .comingSoon, type: .personal)
                    .map { [weak self](items) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        if items.isEmpty {
                            return challenge
                        } else {
                            return  challenge + weakSelf.transformToSection(challenge: items, progress: .comingSoon, type: .personal)
                        }
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](challenge) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .done, type: .personal)
                    .map { [weak self](items) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        if items.isEmpty {
                            return challenge
                        } else {
                            return  challenge + weakSelf.transformToSection(challenge: items, progress: .done, type: .personal)
                        }
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](challenge) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .challenge, type: .personal)
                    .map { [weak self](items) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        if items.isEmpty {
                            return challenge
                        } else {
                            return  challenge + weakSelf.transformToSection(challenge: items, progress: .challenge, type: .personal)
                        }
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
                
            }).asDriver(onErrorJustReturn: [])
        
        moreSelectedO = moreSubject
            .asObservable()
            .asDriverOnErrorJustComplete()
        
        moreMenuSelectedO = moreMenuSubject
            .flatMapLatest { (type) -> Observable<String> in
                switch type {
                case .bagikan:
                    return Observable.just("Tautan telah dibagikan")
                case .salin:
                    return Observable.just("Tautan telah tersalin")
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
    
}
