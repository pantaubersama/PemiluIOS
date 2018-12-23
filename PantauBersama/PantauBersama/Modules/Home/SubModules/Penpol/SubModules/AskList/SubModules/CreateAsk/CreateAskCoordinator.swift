//
//  CreateAskCoordinator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol CreateAskNavigator {
    var finish: Observable<Void>! { get set }
}

class CreateAskCoordinator: BaseCoordinator<Void>, CreateAskNavigator {
    var finish: Observable<Void>!
    
    private let navigationController: UINavigationController
    
    // TODO: replace any with Quiz model
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = CreateAskController()
        let viewModel = CreateAskViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}
