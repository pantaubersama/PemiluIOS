//
//  ProfileCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Networking

protocol ProfileNavigator: LinimasaNavigator, PenpolNavigator, BadgeNavigator {
    func back()
    func launchSetting(user: User) -> Observable<Void>
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void>
    func launchReqCluster() -> Observable<Void>
    func launchUndangAnggota() -> Observable<Void>
}


final class ProfileCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = ProfileController()
        let viewModel = ProfileViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
}

extension ProfileCoordinator: ProfileNavigator {
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func launchSetting(user: User) -> Observable<Void> {
        let settingCoordinator = SettingCoordinator(navigationController: navigationController, data: user)
        return coordinate(to: settingCoordinator)
    }
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void>  {
        switch user.nextStep {
        case 1:
            let identitasCoordinator = IdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: identitasCoordinator)
        case 2:
            let selfIdentitasCoordinator = SelfIdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: selfIdentitasCoordinator)
        case 3:
            let ktpCoordinator = KTPCoordinator(navigationController: navigationController)
            return coordinate(to: ktpCoordinator)
        case 4:
            let signatureCoordinator = SignatureCoordinator(navigationController: navigationController)
            return coordinate(to: signatureCoordinator)
        case 5:
            let successCoordinator = SuccessCoordinator(navigationController: navigationController)
            return coordinate(to: successCoordinator)
        default :
            let identitasCoordinator = IdentitasCoordinator(navigationController: navigationController)
            return coordinate(to: identitasCoordinator)
        }
    }
    func launchReqCluster() -> Observable<Void> {
        let reqClusterCoordinator = ReqClusterCoordinator(navigationController: navigationController)
        return coordinate(to: reqClusterCoordinator)
            .filter({ $0 == .create })
            .mapToVoid()
    }
    
    func launchUndangAnggota() -> Observable<Void> {
        let undangAnggotaCoordinator = UndangAnggotaCoordinator(navigationController: navigationController)
        return coordinate(to: undangAnggotaCoordinator)
    }
    
}

extension ProfileCoordinator: LinimasaNavigator {
    func launchNote() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        return Observable.never()
    }
    
    
    func launchProfile() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchNotifications() {
    }
    
    func launchFilter() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchAddJanji() -> Observable<Void> {
        return Observable.never()
    }
    
    func sharePilpres(data: Any) -> Observable<Void> {
        return Observable.never()
    }
    
    func openTwitter(data: String) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareJanji(data: Any) -> Observable<Void> {
        return Observable.never()
    }
    
}

extension ProfileCoordinator: PenpolNavigator {
    func launchFilter(filterType: FilterType, filterTrigger: AnyObserver<[PenpolFilterModel.FilterItem]>) -> Observable<Void> {
        return Observable.never()
    }
    
    
    func openQuiz(quiz: QuizModel) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareQuiz(quiz: Any) -> Observable<Void> {
        return Observable.never()
    }
    
    func shareTrend(trend: Any) -> Observable<Void> {
        return Observable.never()
    }
    
    func launchCreateAsk() -> Observable<Void> {
        return Observable.never()
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        return Observable.never()
    }
}


extension  ProfileCoordinator: BadgeNavigator {
    func launchShare(id: String) -> Observable<Void> {
        let shareCoordinator = ShareBadgeCoordinator(navigationController: navigationController, id: id)
        return coordinate(to: shareCoordinator)
    }
}
