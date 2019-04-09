//
//  RekapDetailTPSNavigator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking

protocol RekapDetailTPSNavigator {
    func back() -> Observable<Void>
}

final class RekapDetailTPSCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let realCount: RealCount
    
    init(navigationController: UINavigationController, realCount: RealCount) {
        self.navigationController = navigationController
        self.realCount = realCount
    }
    
    override func start() -> Observable<Void> {
        let viewModel = RekapDetailTPSViewModel(navigator: self, realCount: self.realCount)
        let viewController = RekapDetailTPSController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension RekapDetailTPSCoordinator: RekapDetailTPSNavigator {
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
}
