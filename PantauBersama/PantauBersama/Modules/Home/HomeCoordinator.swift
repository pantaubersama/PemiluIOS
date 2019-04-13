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
import Common

class HomeCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let viewControllers: [UINavigationController]
    private var isNewQuiz = false
    var selectedIndex: Int = 1
    
    init(window: UIWindow, isNewQuiz: Bool = false) {
        self.window = window
        self.isNewQuiz = isNewQuiz
        self.viewControllers = PantauBarKind.items
            .map { (t) -> UINavigationController in
                let n = UINavigationController()
//                n.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                n.tabBarItem.title = t.title
                n.tabBarItem.image = t.icon
                n.tabBarItem.selectedImage = t.iconSelected
                return n
            }
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = HomeController()
        viewController.tabBar.isTranslucent = false
        viewController.tabBar.tintColor = Color.primary_red
        viewController.tabBar.barTintColor = UIColor.white
        viewController.viewControllers = viewControllers
        viewController.selectedIndex = self.selectedIndex
        
        let coordinates = viewControllers.enumerated()
            .map { (offset, element) -> Observable<Void> in
                guard let t = PantauBarKind(rawValue: offset) else { return Observable.just(()) }
                switch t {
                    case .linimasa:
                        return coordinate(to: LinimasaCoordinator(navigationController: element))
                    case .penpol:
                        return coordinate(to: PenpolCoordinator(navigationController: element, isNewQuiz: isNewQuiz))
//                    case .wordstadium:
//                        return coordinate(to: WordstadiumCoordinator(navigationController: element))
                    case .merayakan:
                        return coordinate(to: MerayakanCoordinator(navigationController: element))
//                    default:
//                        return coordinate(to: ComingsoonCoordinator(navigationController: element))
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
