//
//  ComingsoonCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift

protocol ComingsoonNavigator {
    func launchSearch() -> Observable<Void>
    func launchProfile() -> Observable<Void>
    func launchNote() -> Observable<Void>
    func launchNotif() -> Observable<Void>
    func launchWeb(link: String) -> Observable<Void>
}

class ComingsoonCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = ComingsoonViewModel(navigator: self)
        let viewController = ComingsoonController()
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension ComingsoonCoordinator: ComingsoonNavigator {
    func launchSearch() -> Observable<Void> {
        let searchCoordinator = SearchCoordinator(navigationController: navigationController)
        return coordinate(to: searchCoordinator)
    }
    
    func launchProfile() -> Observable<Void> {
//        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
//        return coordinate(to: profileCoordinator)
        return Observable.empty()
    }
    
    func launchNote() -> Observable<Void> {
        let noteCoordinator = CatatanCoordinator(navigationController: navigationController)
        return coordinate(to: noteCoordinator)
    }
    
    func launchNotif() -> Observable<Void> {
        return Observable.empty()
    }
    
    func launchWeb(link: String) -> Observable<Void> {
        let wkwebCoordinator = WKWebCoordinator(navigationController: navigationController, url: link)
        return coordinate(to: wkwebCoordinator)
    }
    
}
