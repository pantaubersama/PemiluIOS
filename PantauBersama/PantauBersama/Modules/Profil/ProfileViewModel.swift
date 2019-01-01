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
    var viewWillAppearI: AnyObserver<Void> { get }
}

protocol IProfileViewModelOutput {
    var settingO: Driver<Void>! { get }
    var verifikasiO: Driver<Void>! { get }
    var itemsClusterO: Driver<[SectionOfProfileData]> { get }
    var itemsBadgeO: Driver<[SectionOfProfileData]>! { get }
    var clusterO: Driver<Void>! { get }
    var userDataO: Driver<UserResponse>! { get }
    var errorO: Driver<Error>! { get }
    var informantDataO: Driver<InformantResponse>! { get }
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
    var viewWillAppearI: AnyObserver<Void>
    
    // Output
    var settingO: Driver<Void>!
    var verifikasiO: Driver<Void>!
    var itemsClusterO: Driver<[SectionOfProfileData]>
    var itemsBadgeO: Driver<[SectionOfProfileData]>!
    var clusterO: Driver<Void>!
    var userDataO: Driver<UserResponse>!
    var errorO: Driver<Error>!
    var informantDataO: Driver<InformantResponse>!
    
    
    private let backS = PublishSubject<Void>()
    private let settingS = PublishSubject<Void>()
    private let verifikasiS = PublishSubject<Void>()
    private let clusterS = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let viewWillAppearS = PublishSubject<Void>()
    
    init(navigator: ProfileNavigator) {
        self.navigator = navigator
        self.navigatorLinimasa = navigator
        self.navigatorPenpol = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
        settingI = settingS.asObserver()
        verifikasiI = verifikasiS.asObserver()
        clusterI = clusterS.asObserver()
        viewWillAppearI = viewWillAppearS.asObserver()
        
        // MARK
        // Get user data from cloud and Local
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let cloud = NetworkService.instance.requestObject(
            PantauAuthAPI.me,
            c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                AppState.saveMe(response)
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        let userData = viewWillAppearS
            .flatMapLatest({ Observable.merge(local, cloud)})
        
        // MARK
        // Get Informations cloud
        let informant = NetworkService.instance.requestObject(
            PantauAuthAPI.meInformant,
            c: BaseResponse<InformantResponse>.self)
            .map({ $0.data })
//            .do(onSuccess: { (response) in
//                AppState.saveInformant(response)
//            })
            .do(onSuccess: { (response) in
                AppState.saveInformant(response)
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .asObservable()
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .catchErrorJustComplete()
        
        // MARK
        // Click setting with latest user data
        let setting = settingS
            .withLatestFrom(userData)
            .flatMapLatest { (user) -> Observable<Void> in
                return navigator.launchSetting(user: user.user)
            }
            .asDriver(onErrorJustReturn: ())
        
        // MARK
        // Get verifications steps
        let verifications = NetworkService.instance.requestObject(
            PantauAuthAPI.verifications,
            c: BaseResponse<VerificationsResponse>.self)
            .map({ $0.data.user })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        
        // MARK
        // Click verifikasi with latest user data
        let verifikasi = verifikasiS
            .withLatestFrom(verifications)
            .flatMapLatest { (user) -> Observable<Void> in
                return navigator.launchVerifikasi(user: user)
            }
            .asDriver(onErrorJustReturn: ())
        
        let cluster = clusterS
            .flatMapLatest({ navigator.launchReqCluster() })
            .asDriver(onErrorJustReturn: ())
        
        
        // MARK
        // Get Badges me
        let badge = NetworkService.instance
            .requestObject(PantauAuthAPI.badges(page: 1, perPage: 3), c: BaseResponse<BadgesResponse>.self)
            .map({ $0.data })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        settingO = setting
        verifikasiO = verifikasi
        
        itemsClusterO = userData
            .map { (data) -> [SectionOfProfileData] in
                return [SectionOfProfileData(items: [ClusterCellConfigured.init(item: ClusterCell.Input(data: data.user))])]
            }.asDriver(onErrorJustReturn: [])
        
        // MARK
        // Get Observable<[Badges>
        // Into List
        itemsBadgeO = badge
            .map{ (list) -> [SectionOfProfileData] in
                return list.achieved.compactMap({ (badge) -> SectionOfProfileData in
                    return SectionOfProfileData(items: [BadgeCellConfigured(item: BadgeCell.Input(badges: badge, isAchieved: true))])
                })
            }
            .asDriverOnErrorJustComplete()
        
        
        clusterO = cluster
        userDataO = userData.asDriverOnErrorJustComplete()
        informantDataO = informant.asDriverOnErrorJustComplete()
        errorO = errorTracker.asDriver()
    }
    
}
