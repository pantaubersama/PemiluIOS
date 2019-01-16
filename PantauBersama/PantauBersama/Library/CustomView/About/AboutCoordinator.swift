//
//  AboutCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 16/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift


protocol AboutNavigator {
    func back()
    func linsensi(link: String) -> Observable<Void>
}


final class AboutCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = AboutViewModel(navigator: self)
        let viewController = AboutController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension AboutCoordinator: AboutNavigator {
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func linsensi(link: String) -> Observable<Void> {
        let wkwebCoordinator = WKWebCoordinator(navigationController: navigationController, url: link)
        return coordinate(to: wkwebCoordinator)
    }
    
    
}
