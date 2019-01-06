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
    var viewWillAppearI: AnyObserver<Void> { get }
    var reqClusterI: AnyObserver<Void> { get }
}

protocol IProfileViewModelOutput {
    var settingO: Driver<Void>! { get }
    var verifikasiO: Driver<Void>! { get }
    var itemsBadgeO: Driver<[SectionOfProfileData]>! { get }
    var userDataO: Driver<UserResponse>! { get }
    var errorO: Driver<Error>! { get }
    var reqClusterO: Driver<Void> { get }
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
    var viewWillAppearI: AnyObserver<Void>
    var reqClusterI: AnyObserver<Void>
    
    // Output
    var settingO: Driver<Void>!
    var verifikasiO: Driver<Void>!
    var itemsBadgeO: Driver<[SectionOfProfileData]>!
    var userDataO: Driver<UserResponse>!
    var errorO: Driver<Error>!
    var reqClusterO: Driver<Void>
    
    
    private let backS = PublishSubject<Void>()
    private let settingS = PublishSubject<Void>()
    private let verifikasiS = PublishSubject<Void>()
    private let reqClusterS = PublishSubject<Void>()
    private let activityIndicator = ActivityIndicator()
    private let errorTracker = ErrorTracker()
    private let viewWillAppearS = PublishSubject<Void>()
    private let viewModel = ClusterCellViewModel()
    
    init(navigator: ProfileNavigator) {
        self.navigator = navigator
        self.navigatorLinimasa = navigator
        self.navigatorPenpol = navigator
        self.navigator.finish = backS
        
        // MARK
        // Input
        backI = backS.asObserver()
        settingI = settingS.asObserver()
        verifikasiI = verifikasiS.asObserver()
        viewWillAppearI = viewWillAppearS.asObserver()
        reqClusterI = reqClusterS.asObserver()
        
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

        // MARK
        // Get Badges me
        let badge = NetworkService.instance
            .requestObject(PantauAuthAPI.badges(page: 1, perPage: 3), c: BaseResponse<BadgesResponse>.self)
            .map({ $0.data })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        
        // MARK
        // Output
        settingO = setting
        verifikasiO = verifikasi
        
        itemsBadgeO = badge
            .map{ (list) -> [SectionOfProfileData] in
                return list.achieved.compactMap({ (badge) -> SectionOfProfileData in
                    return SectionOfProfileData(items: [BadgeCellConfigured(item: BadgeCell.Input(badges: badge, isAchieved: true))])
                })
            }
            .asDriverOnErrorJustComplete()
    
        userDataO = userData.asDriverOnErrorJustComplete()
        errorO = errorTracker.asDriver()
        reqClusterO = reqClusterS
            .flatMapLatest({ navigator.launchReqCluster() })
            .asDriverOnErrorJustComplete()
    }
    
}
