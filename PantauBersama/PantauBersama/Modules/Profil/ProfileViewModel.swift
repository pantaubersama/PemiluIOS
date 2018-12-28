//
//  ProfileViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

protocol IProfileViewModelInput {
    var backI: AnyObserver<Void> { get }
    var settingI: AnyObserver<Void> { get }
    var verifikasiI: AnyObserver<Void> { get }
    var clusterI: AnyObserver<Void> { get }
}

protocol IProfileViewModelOutput {
    var settingO: Driver<Void>! { get }
    var verifikasiO: Driver<Void>! { get }
    var itemsO: Driver<[SectionOfProfileData]> { get }
    var clusterO: Driver<Void>! { get }
    var userDataO: Driver<UserResponse>! { get }
    var errorO: Driver<Error>! { get }
}

protocol IProfileViewModel {
    var input: IProfileViewModelInput { get }
    var output: IProfileViewModelOutput { get }
    
    var navigator: ProfileNavigator! { get }
    var navigatorLinimasa: LinimasaNavigator! { get }
    var navigatorPenpol: PenpolNavigator! { get }

}

final class ProfileViewModel: IProfileViewModel, IProfileViewModelInput, IProfileViewModelOutput {
    
    
    var input: IProfileViewModelInput { return self }
    var output: IProfileViewModelOutput { return self }
    
    var navigator: ProfileNavigator!
    var navigatorLinimasa: LinimasaNavigator!
    var navigatorPenpol: PenpolNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    var settingI: AnyObserver<Void>
    var verifikasiI: AnyObserver<Void>
    var clusterI: AnyObserver<Void>
    
    // Output
    var settingO: Driver<Void>!
    var verifikasiO: Driver<Void>!
    var itemsO: Driver<[SectionOfProfileData]>
    var clusterO: Driver<Void>!
    var userDataO: Driver<UserResponse>!
    var errorO: Driver<Error>!
    
    
    private let backS = PublishSubject<Void>()
    private let settingS = PublishSubject<Void>()
    private let verifikasiS = PublishSubject<Void>()
    private let clusterS = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    
    init(navigator: ProfileNavigator) {
        self.navigator = navigator
        self.navigatorLinimasa = navigator
        self.navigatorPenpol = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
        settingI = settingS.asObserver()
        verifikasiI = verifikasiS.asObserver()
        clusterI = clusterS.asObserver()
        
        
        let setting = settingS
            .flatMapLatest({ navigator.launchSetting() })
            .asDriver(onErrorJustReturn: ())
        
        let verifikasi = verifikasiS
            .flatMapLatest({ navigator.launchVerifikasi() })
            .asDriver(onErrorJustReturn: ())
        
        let cluster = clusterS
            .flatMapLatest({ navigator.launchReqCluster() })
            .asDriver(onErrorJustReturn: ())
        
        let userData = NetworkService.instance.requestObject(
            PantauAuthAPI.me,
            c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
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
        clusterO = cluster
        userDataO = userData.asDriverOnErrorJustComplete()
        
        errorO = errorTracker.asDriver()
    }
    
}
