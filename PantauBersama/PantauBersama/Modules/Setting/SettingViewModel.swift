//
//  SettingViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ISettingViewModelInput {
    var backI: AnyObserver<Void> { get }
    var itemSelectedI: AnyObserver<IndexPath> { get }
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
    
    // Output
    var itemsO: Driver<[SectionOfSettingData]>
    var itemSelectedO: Driver<Void>
    
    private let backS = PublishSubject<Void>()
    private let editS = PublishSubject<Int>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    
    init(navigator: SettingNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
        itemSelectedI = itemSelectedS.asObserver()
        
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
        
        let itemProfile: Observable<[SectionOfProfileInfoData]>
        
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
                    return navigator.launchVerifikasi(isVerified: true)
                case .updateProfile:
                    return navigator.launchProfileEdit()
                default:
                    return Observable.empty()
                }
        }
        
        itemsO = items
        itemSelectedO = itemSelected.asDriverOnErrorJustComplete()
        
    }
    
}
