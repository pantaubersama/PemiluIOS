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


protocol RekapNavigator {
//    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchDetail() -> Observable<Void>
}

class RekapCoordinator: BaseCoordinator<Void> {
    var navigationController: UINavigationController!
    private var filterCoordinator: PenpolFilterCoordinator!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = RekapController()
//        let viewModel = RekapViewModel(navigator: self)
//        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}


