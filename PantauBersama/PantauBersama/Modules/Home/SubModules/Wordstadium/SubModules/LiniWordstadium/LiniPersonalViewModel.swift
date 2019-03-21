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
    var itemSelectedI: AnyObserver<IndexPath>
    var collectionSelectedI: AnyObserver<Challenge>
    
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
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let collectionSelectedSubject = PublishSubject<Challenge>()
    
    internal let errorTracker = ErrorTracker()
    internal let activityIndicator = ActivityIndicator()
    internal let headerViewModel = BannerHeaderViewModel()
    
    init(navigator: WordstadiumNavigator, showTableHeader: Bool) {
        refreshI = refreshSubject.asObserver()
        moreI = moreSubject.asObserver()
        moreMenuI = moreMenuSubject.asObserver()
        seeMoreI = seeMoreSubject.asObserver()
        itemSelectedI = itemSelectedSubject.asObserver()
        collectionSelectedI = collectionSelectedSubject.asObserver()
        
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
                return navigator.launchWordstadiumList(progressType: wordstadium.itemType, liniType: wordstadium.type)
            })
            .asDriverOnErrorJustComplete()
        
        let colectionSelected = collectionSelectedSubject
            .asObservable()
            .flatMapLatest({ (challenge) -> Observable<Void> in
                return navigator.launchLiveChallenge(wordstadium: challenge)
            })
            .asDriverOnErrorJustComplete()

        
        // MARK:
        // Get challenge list
        let itemChallenges = refreshSubject.startWith(())
            .flatMapLatest({ [weak self](_) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .inProgress, type: .personal)
                    .map { [weak self](data) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        return  weakSelf.transformToSection(data: data, progress: .inProgress, type: .personal)
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](challenge) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .comingSoon, type: .personal)
                    .map { [weak self](data) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        return  challenge + weakSelf.transformToSection(data: data, progress: .comingSoon, type: .personal)
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](challenge) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .done, type: .personal)
                    .map { [weak self](data) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        return  challenge + weakSelf.transformToSection(data: data, progress: .done, type: .personal)
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
            })
            .flatMapLatest({ [weak self](challenge) -> Observable<[SectionWordstadium]> in
                guard let weakSelf = self else { return Observable.empty() }
                return weakSelf.getChallenge(progress: .challenge, type: .personal)
                    .map { [weak self](data) -> [SectionWordstadium] in
                        guard let weakSelf = self else { return [] }
                        return  challenge + weakSelf.transformToSection(data: data, progress: .challenge, type: .personal)
                    }
                    .trackActivity(weakSelf.activityIndicator)
                    .trackError(weakSelf.errorTracker)
                    .asObservable()
                    .catchErrorJustReturn([])
                
            }).asDriver(onErrorJustReturn: [])
        
        itemsO = itemChallenges
        
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
                case .hapus:
                    return Observable.just("Challenge berhasil di hapus")
                }
            }
            .asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedSubject
            .withLatestFrom(itemChallenges) { (indexPath, challenges) -> CellModel in
                return challenges[indexPath.section].items[indexPath.row]
            }
            .flatMapLatest({ (item) -> Observable<Void> in
                switch item {
                case .standard(let challenge):
                    if challenge.progress == .liveNow {
                        return navigator.launchLiveChallenge(wordstadium: challenge)
                    } else {
                        return navigator.launchChallenge(wordstadium: challenge)
                    }
                default :
                    return Observable.empty()
                }
                
            })
            .asDriverOnErrorJustComplete()
        
        
        itemSelectedO = Driver.merge(infoSelected,seeMoreSelected,itemSelected,colectionSelected)
        
    }
    
    private func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "debat_personal"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
    
}
