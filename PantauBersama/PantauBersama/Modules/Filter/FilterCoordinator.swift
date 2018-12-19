//
//  FilterCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift


protocol FilterNavigator {
    
}

class FilterCoordinator: BaseCoordinator<Void> {
    
    internal let navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        print("starting.....")
        let viewController = FilterViewController()
        let viewModel = FilterViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.output.backO
            .do(onNext: { [unowned self] _ in
                self.navigationController.popViewController(animated: true)
            })
            .asObservable()
    }
}

extension FilterCoordinator: FilterNavigator {}
