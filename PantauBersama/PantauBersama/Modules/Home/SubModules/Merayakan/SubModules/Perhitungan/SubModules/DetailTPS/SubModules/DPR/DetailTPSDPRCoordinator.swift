//
//  DetailTPSDPRCoordinator.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 06/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Networking

protocol DetailTPSDPRNavigator {
    func back() -> Observable<Void>
}

class DetailTPSDPRCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let type: TPSDPRType
    private let realCount: RealCount
    
    init(navigationController: UINavigationController, type: TPSDPRType, realCount: RealCount) {
        self.type = type
        self.navigationController = navigationController
        self.realCount = realCount
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSDPRController()
        let viewModel = DetailTPSDPRViewModel(navigator: self, realCount: self.realCount)
        viewController.viewModel = viewModel
        viewController.type = type
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension DetailTPSDPRCoordinator: DetailTPSDPRNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
