//
//  BannerInfoCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import Networking

class BannerInfoCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let bannerInfo: BannerInfo
    
    
    init(navigationController: UINavigationController, bannerInfo: BannerInfo) {
        self.navigationController = navigationController
        self.bannerInfo = bannerInfo
    }
    override func start() -> Observable<Void> {
        let viewController = BannerInfoController()
        let viewModel = BannerInfoViewModel(bannerInfo: bannerInfo)
        viewController.viewModel = viewModel
        
        let presentedNavController = UINavigationController(rootViewController: viewController)
        navigationController.present(presentedNavController, animated: true, completion: nil)
        
        return viewModel.output.finish.do(onNext: { [weak self](_) in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }).asObservable()
    }
    
}
