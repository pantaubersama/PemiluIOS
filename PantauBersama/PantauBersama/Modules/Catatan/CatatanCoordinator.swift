//
//  CatatanCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift

protocol CatatanNavigator {
   var finish: Observable<Void>! { get set }
}

final class CatatanCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = CatatanViewModel(navigator: self)
        let viewController = CatatanController()
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
    
}

extension CatatanCoordinator: CatatanNavigator {
    
}
