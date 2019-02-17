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


protocol MerayakanNavigator: RekapNavigator {
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchDetail() -> Observable<Void>
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
    func launchDetail() -> Observable<Void> {
        let bannerInfoCoordinator = DetailCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    
}
