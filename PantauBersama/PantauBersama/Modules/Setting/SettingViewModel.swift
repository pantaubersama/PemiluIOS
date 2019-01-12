//
//  SettingViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import TwitterKit

protocol ISettingViewModelInput {
    var backI: AnyObserver<Void> { get }
    var itemSelectedI: AnyObserver<IndexPath> { get }
    var viewWillAppearTrigger: AnyObserver<Void> { get }
    var itemTwitterI: AnyObserver<String> { get }
}

protocol ISettingViewModelOutput {
    var itemsO: Driver<[SectionOfSettingData]> { get }
    var itemSelectedO: Driver<Void> { get }
    var itemTwitterO: Driver<String> { get }
}

protocol ISettingViewModel {
    var input: ISettingViewModelInput { get }
    var output: ISettingViewModelOutput { get }
    
    var navigator: SettingNavigator! { get }
}

final class SettingViewModel: ISettingViewModel, ISettingViewModelInput, ISettingViewModelOutput {
    
    var input: ISettingViewModelInput { return self }
    var output: ISettingViewModelOutput { return self }
    
    var navigator: SettingNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    var itemSelectedI: AnyObserver<IndexPath>
    var viewWillAppearTrigger: AnyObserver<Void>
    var itemTwitterI: AnyObserver<String>
    
    // Output
    var itemsO: Driver<[SectionOfSettingData]>
    var itemSelectedO: Driver<Void>
    var itemTwitterO: Driver<String>
    
    private let backS = PublishSubject<Void>()
    private let editS = PublishSubject<Int>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let userData: User
    private let viewWillAppearS = PublishSubject<Void>()
    private let itemTwitterS = PublishSubject<String>()
    
    init(navigator: SettingNavigator, data: User) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.userData = data
    
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        itemSelectedI = itemSelectedS.asObserver()
        viewWillAppearTrigger = viewWillAppearS.asObserver()
        itemTwitterI = itemTwitterS.asObserver()
        
        let item = Observable.just([
                SectionOfSettingData(header: nil, items: [
                SettingData.updateProfile,
                SettingData.updatePassword,
                SettingData.updateDataLapor,
                SettingData.verifikasi,
                SettingData.badge
            ]),
            SectionOfSettingData(header: "Twitter", items: [
                SettingData.twitter
            ]),
            SectionOfSettingData(header: "Facebook", items: [
                SettingData.facebook
            ]),
            SectionOfSettingData(header: "Cluster", items: [
                SettingData.cluster
            ]),
            SectionOfSettingData(header: "Support", items: [
                SettingData.pusatBantuan,
                SettingData.pedomanKomunitas,
                SettingData.tentang,
                SettingData.rate,
                SettingData.share
            ]),
        SectionOfSettingData(header: nil, items: [
            SettingData.logout ])])
        
        let items = viewWillAppearS
            .withLatestFrom(item)
            .asDriverOnErrorJustComplete()
        
        let verifikasi = NetworkService.instance.requestObject(
            PantauAuthAPI.verifications,
            c: BaseResponse<VerificationsResponse>.self)
            .map({ $0.data.user })
            .asObservable()
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
        
        let itemSelected = itemSelectedS
            .withLatestFrom(items) { indexPath, item in
                return item[indexPath.section].items[indexPath.row]
            }
            .flatMap { (type) -> Observable<Void> in
                switch type {
                case .logout:
                    return navigator.launchSignOut()
                case .badge:
                    return navigator.launchBadge()
                case .verifikasi:
                    // MARK
                    // Fetch verifications data
                    return verifikasi.flatMapLatest({ navigator.launchVerifikasi(user: $0)})
                    
                case .updateProfile:
                    return navigator.launchProfileEdit(data: data, type: ProfileHeaderItem.editProfile)
                case .updatePassword:
                    return navigator.launchProfileEdit(data: data, type: ProfileHeaderItem.editPassword)
                case .updateDataLapor:
                    return navigator.launchProfileEdit(data: data, type: ProfileHeaderItem.editDataLapor)
                case .cluster:
                    // MARK
                    // If user data cluster == nil return alert
                    if data.cluster == nil {
                        return navigator.launchAlertUndang()
                    } else if data.isModerator == true {
                        return navigator.launchUndang(data: data)
                    } else {
                        return navigator.launchAlertCluster()
                    }
                case .twitter:
                    if data.twitter == true {
                        return navigator.launchTwitterAlert()
                    } else {
                        return TWTRTwitter.sharedInstance().loginTwitter()
                            .flatMapLatest({ (session) -> Observable<Void> in
                                UserDefaults.Account.set("Connected as \(session.userName)", forKey: .usernameTwitter)
                                UserDefaults.Account.set(session.userID, forKey: .userIdTwitter)
                                return NetworkService.instance
                                    .requestObject(PantauAuthAPI
                                        .accountsConnect(
                                            type: "twitter",
                                            oauthToken: session.authToken,
                                            oauthSecret: session.authTokenSecret),
                                                   c: BaseResponse<AccountResponse>.self)
                                    .trackError(errorTracker)
                                    .trackActivity(activityIndicator)
                                    .catchErrorJustComplete()
                                    .mapToVoid()
                            })
                            .mapToVoid()
                    }
                default:
                    return Observable.empty()
                }
        }
        
        itemsO = items
        itemSelectedO = itemSelected.asDriverOnErrorJustComplete()
        itemTwitterO = itemTwitterS.asDriver(onErrorJustReturn: "")
    }
    
}
