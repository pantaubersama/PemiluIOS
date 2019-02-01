//
//  NotificationCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol NotificationNavigator {
    func back() -> Observable<Void>
}

final class NotificationCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = NotificationViewModel(navigator: self)
        let viewController = NotificationController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension NotificationCoordinator: NotificationNavigator {
    
    func back() -> Observable<Void> {
        navigationController.popViewController(animated: true)
        return Observable.empty()
    }
    
}
