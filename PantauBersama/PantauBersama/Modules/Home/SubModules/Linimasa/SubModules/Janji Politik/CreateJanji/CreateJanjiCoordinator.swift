//
//  CreateJanjiCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

class CreateJanjiCoordinator: BaseCoordinator<SelectionResult> {
    
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = CreateJanjiController()
        let viewModel = CreateJanjiViewModel()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        
        return viewModel.output.actionO
            .do(onNext: { [weak self] (_) in
                self?.navigationController.popViewController(animated: true)
            })
            .asObservable()
    }
}

