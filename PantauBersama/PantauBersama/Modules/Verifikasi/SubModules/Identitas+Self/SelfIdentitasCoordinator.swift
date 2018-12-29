//
//  SelfIdentitasCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 29/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol SelfIdentitasNavigator {
    var finish: Observable<Void>! { get set }
}

class SelfIdentitasCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = SelfIdentitasViewModel(navigator: self)
        let viewController = SelfIdentitasController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension SelfIdentitasCoordinator: SelfIdentitasNavigator {
    
}
