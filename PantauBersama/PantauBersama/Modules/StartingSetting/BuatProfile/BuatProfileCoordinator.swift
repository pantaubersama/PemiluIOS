//
//  BuatProfileCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol BuatProfileNavigator {
    func nextStep() -> Observable<Void>
}

final class BuatProfileCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    override func start() -> Observable<Void> {
        let viewModel = BuatProfileViewModel(navigator: self)
        let viewController = BuatProfileController()
        viewController.viewModel = viewModel
        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return Observable.empty()
    }
    
}


extension BuatProfileCoordinator: BuatProfileNavigator {
    func nextStep() -> Observable<Void> {
        let sosmedCoordinator = SosmedCoordinator(navigationController: self.navigationController)
        return coordinate(to: sosmedCoordinator)
    }
}
