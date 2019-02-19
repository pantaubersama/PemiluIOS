//
//  LiveDebatCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

public protocol LiveDebatNavigator {
    func back() -> Observable<Void>
    func launchDetail() -> Observable<Void>
    func showComment() -> Observable<Void>
}

public enum DebatViewType {
    case watch
    case myTurn
    case theirTurn
    case done
}

class LiveDebatCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let viewType: DebatViewType
    
    init(navigationController: UINavigationController, viewType: DebatViewType) {
        self.navigationController = navigationController
        self.viewType = viewType
    }
    
    override func start() -> Observable<Void> {
        let viewController = LiveDebatController()
        let viewModel = LiveDebatViewModel(navigator: self, viewType: .watch)
        viewController.hidesBottomBarWhenPushed = true
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}

extension LiveDebatCoordinator: LiveDebatNavigator {
    func back() -> Observable<Void> {
        self.navigationController.popViewController(animated: true)
        return Observable.never()
    }
    
    func launchDetail() -> Observable<Void> {
        let debatDetailCoordinator = DebatDetailCoordinator(navigationController: self.navigationController)
        return coordinate(to: debatDetailCoordinator)
    }
    
    func showComment() -> Observable<Void> {
        let debatCommentCoordinator = DebatCommentCoordinator(navigationController: self.navigationController)
        return coordinate(to: debatCommentCoordinator)
    }
}
