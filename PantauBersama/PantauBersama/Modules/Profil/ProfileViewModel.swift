//
//  ProfileViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol IProfileViewModelInput {
    var backI: AnyObserver<Void> { get }
    var settingI: AnyObserver<Void> { get }
    var verifikasiI: AnyObserver<Void> { get }
}

protocol IProfileViewModelOutput {
    var settingO: Driver<Void>! { get }
    var verifikasiO: Driver<Void>! { get }
    var itemsO: Driver<[SectionOfProfileData]> { get }
}

protocol IProfileViewModel {
    var input: IProfileViewModelInput { get }
    var output: IProfileViewModelOutput { get }
    
    var navigator: ProfileNavigator! { get }
}

final class ProfileViewModel: IProfileViewModel, IProfileViewModelInput, IProfileViewModelOutput {
    
    var input: IProfileViewModelInput { return self }
    var output: IProfileViewModelOutput { return self }
    
    var navigator: ProfileNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    var settingI: AnyObserver<Void>
    var verifikasiI: AnyObserver<Void>
    
    // Output
    var settingO: Driver<Void>!
    var verifikasiO: Driver<Void>!
    var itemsO: Driver<[SectionOfProfileData]>
    
    private let backS = PublishSubject<Void>()
    private let settingS = PublishSubject<Void>()
    private let verifikasiS = PublishSubject<Void>()
    
    init(navigator: ProfileNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
        settingI = settingS.asObserver()
        verifikasiI = verifikasiS.asObserver()
        
        let setting = settingS
            .flatMapLatest({ navigator.launchSetting() })
            .asDriver(onErrorJustReturn: ())
        
        let verifikasi = verifikasiS
            .flatMapLatest({ navigator.launchVerifikasi() })
            .asDriver(onErrorJustReturn: ())
        
        settingO = setting
        verifikasiO = verifikasi
        itemsO = Driver.just([
            SectionOfProfileData(header: GroupProfileInfoData.cluster.title,
                                 items: [
                                    ClusterCellConfigured(item: ClusterCell.Input())
                ]),
            SectionOfProfileData(header: GroupProfileInfoData.biodata.title,
                                 items: [
                                    BiodataCellConfigured(item: IconTableCell.Input())
                ]),
            SectionOfProfileData(header: GroupProfileInfoData.badge.title,
                                 items: [
                                    BadgeCellConfigured(item: BadgeCell.Input())
                ])
            ])
    }
    
}
