//
//  WKWebCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 11/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol WKWebNavigator {
    var finish: Observable<Void>! { get set }
}

final class WKWebCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    private let url: String
    
    init(navigationController: UINavigationController, url: String) {
        self.navigationController = navigationController
        self.url = url
    }
    
    override func start() -> Observable<Void> {
        let viewController = WKWebviewCustom()
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension WKWebCoordinator: WKWebNavigator {
    
}
