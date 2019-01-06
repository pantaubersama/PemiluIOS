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

protocol ProfileNavigator: LinimasaNavigator, PenpolNavigator {
    var finish: Observable<Void>! { get set }
    func launchSetting(user: User) -> Observable<Void>
    func launchVerifikasi(user: VerificationsResponse.U) -> Observable<Void>
    func launchReqCluster() -> Observable<Void>
}


final class ProfileCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = ProfileController()
        let viewModel = ProfileViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension ProfileCoordinator: ProfileNavigator {
    
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
    
    func openInfoPenpol(infoType: PenpolInfoType) -> Observable<Void> {
        return Observable.never()
    }
    
    func openQuiz(quiz: Any) -> Observable<Void> {
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
