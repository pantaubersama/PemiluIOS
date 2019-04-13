//
//  RekapCoordinator.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Networking


protocol MerayakanNavigator: RekapNavigator, PerhitunganNavigator {
    func launchSearch() -> Observable<Void>
    func launchNotifications() -> Observable<Void>
}

class MerayakanCoordinator: BaseCoordinator<Void> {
    var navigationController: UINavigationController!
    private var filterCoordinator: PenpolFilterCoordinator!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = MerayakanController()
        let viewModel = MerayakanViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension MerayakanCoordinator : MerayakanNavigator {
    func launchBanner(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    
    func launchDetail(item: Region) -> Observable<Void> {
        let rekapList = RekapListCoordinator(navigationController: navigationController, region: item)
        return coordinate(to: rekapList)
    }
    
    func launchSearch() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
    
    func launchKecamatan() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
    
    func launchTps() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchNotifications() -> Observable<Void> {
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        return coordinate(to: notificationCoordinator)
    }
}
