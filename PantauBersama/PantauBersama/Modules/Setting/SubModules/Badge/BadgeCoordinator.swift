//
//  BadgeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//


import UIKit
import RxSwift
import Common

protocol BadgeNavigator {
    func back()
    func launchShare() -> Observable<Void>
}

final class BadgeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = BadgeController()
        let viewModel = BadgeViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension BadgeCoordinator: BadgeNavigator {
    func back() {
        navigationController.popViewController(animated: true)
    }
    func launchShare() -> Observable<Void> {
        let shareCoordinator = ShareBadgeCoordinator(navigationController: navigationController)
        return coordinate(to: shareCoordinator)
    }
}

