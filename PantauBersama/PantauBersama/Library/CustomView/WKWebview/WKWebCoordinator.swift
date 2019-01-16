//
//  WKWebCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 11/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol WKWebNavigator {
    func back()
}

final class WKWebCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let url: String
    
    init(navigationController: UINavigationController, url: String) {
        self.navigationController = navigationController
        self.url = url
    }
    
    override func start() -> Observable<Void> {
        let viewModel = WKWebViewModel(navigator: self, url: url)
        let viewController = WKWebviewCustom()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return Observable.empty()
    }
    
}

extension WKWebCoordinator: WKWebNavigator {
    func back() {
        navigationController.popViewController(animated: true)
    }
}
