//
//  IdentitasCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import Common


protocol IdentitasNavigator {
    func back() -> Observable<Void>
}

class IdentitasCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = IdentitasController()
        let viewModel = IdentitasViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return Observable.never()
    }
    
}

extension IdentitasCoordinator: IdentitasNavigator {
    func back() -> Observable<Void> {
        let coordinator = OnboardingCoordinator(window: self.window)
        return coordinate(to: coordinator)
    }
}
