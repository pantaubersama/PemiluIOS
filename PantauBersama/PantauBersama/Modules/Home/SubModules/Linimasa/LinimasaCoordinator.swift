//
//  LinimasaCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift

protocol LinimasaNavigator {
    func launchProfile()
    func launchNotifications()
    func launchFilter() -> Observable<Void>
    func launchAddJanji() -> Observable<Void>
}




class LinimasaCoordinator: BaseCoordinator<Void> {
    
    var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = LinimasaController()
        let viewModel = LinimasaViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: true)
        return Observable.never()
    }
}

extension LinimasaCoordinator: LinimasaNavigator {
    
    func launchFilter() -> Observable<Void> {
        let filterCoordinator = FilterCoordinator(navigationController: navigationController)
        return coordinate(to: filterCoordinator)
    }
    
    func launchAddJanji() -> Observable<Void> {
        let janjiCoordinator = CreateJanjCoordinator(navigationController: navigationController)
        return coordinate(to: janjiCoordinator)
    }
    
    
    func launchProfile() {
        
    }
    
    func launchNotifications() {
        
    }
}
