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

protocol ISettingViewModelInput {
    var backI: AnyObserver<Void> { get }
    var itemSelectedI: AnyObserver<IndexPath> { get }
    var viewWillAppearTrigger: AnyObserver<Void> { get }
}

protocol ISettingViewModelOutput {
    var itemsO: Driver<[SectionOfSettingData]> { get }
    var itemSelectedO: Driver<Void> { get }
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
    
    // Output
    var itemsO: Driver<[SectionOfSettingData]>
    var itemSelectedO: Driver<Void>
    
    private let backS = PublishSubject<Void>()
    private let editS = PublishSubject<Int>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private let userData: User
    private let viewWillAppearS = PublishSubject<Void>()
    
    
    init(navigator: SettingNavigator, data: User) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.userData = data
    
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        itemSelectedI = itemSelectedS.asObserver()
        viewWillAppearTrigger = viewWillAppearS.asObserver()
        
        let items = Driver.just([
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
                SettingData.logout
                ])
            ])
        
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
                    } else {
                        return navigator.launchUndang()
                    }
                default:
                    return Observable.empty()
                }
        }
        
        itemsO = items
        itemSelectedO = itemSelected.asDriverOnErrorJustComplete()
        
    }
    
}
