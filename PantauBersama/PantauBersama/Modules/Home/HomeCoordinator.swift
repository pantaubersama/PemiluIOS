//
//  HomeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let viewControllers: [UINavigationController]
    
    init(window: UIWindow) {
        self.window = window
        self.viewControllers = PantauBarKind.items
            .map { (t) -> UINavigationController in
                let n = UINavigationController()
                n.tabBarItem.title = t.title
                n.tabBarItem.image = t.icon
                return n
            }
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = HomeController()
        viewController.tabBar.isTranslucent = false
        viewController.tabBar.backgroundColor = UIColor.black
        viewController.tabBar.tintColor = UIColor.red
        viewController.tabBar.barTintColor = UIColor.white
        viewController.viewControllers = viewControllers
        
        let coordinates = viewControllers.enumerated()
            .map { (offset, element) -> Observable<Void> in
                guard let t = PantauBarKind(rawValue: offset) else { return Observable.just(()) }
                switch t {
                    case .linimasa:
                        return coordinate(to: LinimasaCoordinator(navigationController: element))
                    default:
                        return coordinate(to: LinimasaCoordinator(navigationController: element))
                }
                
            }
        Observable.merge(coordinates)
            .subscribe()
            .disposed(by: disposeBag)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        return Observable.never()
    }
    
}
