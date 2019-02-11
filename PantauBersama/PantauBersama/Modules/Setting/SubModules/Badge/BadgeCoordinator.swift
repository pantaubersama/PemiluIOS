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
    func launchShare(id: String) -> Observable<Void>
}

final class BadgeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    private var userId: String? = nil
    
    init(navigationController: UINavigationController, userId: String) {
        self.navigationController = navigationController
        self.userId = userId
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = BadgeController()
        let viewModel = BadgeViewModel(navigator: self, userId: userId)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension BadgeCoordinator: BadgeNavigator {
    func back() {
        navigationController.popViewController(animated: true)
    }
    func launchShare(id: String) -> Observable<Void> {
        let shareCoordinator = ShareBadgeCoordinator(navigationController: navigationController, id: id)
        return coordinate(to: shareCoordinator)
    }
}

