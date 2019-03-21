//
//  DebatCommentCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

protocol DebatCommentNavigator {
    func dismiss() -> Observable<Void>
}

class DebatCommentCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let viewType: DebatViewType
    
    init(navigationController: UINavigationController, viewType: DebatViewType) {
        self.navigationController = navigationController
        self.viewType = viewType
    }
    
    override func start() -> Observable<Void> {
        let viewController = DebatCommentController()
        let viewModel = DebatCommentViewModel(navigator: self, viewType: viewType)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .overCurrentContext
        
//        let nav = UINavigationController(rootViewController: viewController)
        
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.never()
    }
}

extension DebatCommentCoordinator: DebatCommentNavigator {
    func dismiss() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        return Observable.never()
    }
}
