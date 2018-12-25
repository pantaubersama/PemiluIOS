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
}

protocol ISettingViewModelOutput {
    var itemsO: Driver<[SectionOfSettingData]> { get }
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
    
    // Output
    var itemsO: Driver<[SectionOfSettingData]>
    
    private let backS = PublishSubject<Void>()
    
    init(navigator: SettingNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
        
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
        
        itemsO = items
    }
    
}
