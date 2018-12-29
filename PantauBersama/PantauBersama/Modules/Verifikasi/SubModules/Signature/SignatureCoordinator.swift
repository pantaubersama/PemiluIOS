//
//  SignatureCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SignatureNavigator {
    var finish: Observable<Void>! { get set }
    func launchSuccess() -> Observable<Void>
}

class SignatureCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = SignatureViewModel(navigator: self)
        let viewController = SignatureController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension SignatureCoordinator: SignatureNavigator {
    func launchSuccess() -> Observable<Void> {
        let successCoordinator = SuccessCoordinator(navigationController: navigationController)
        return coordinate(to: successCoordinator)
    }
}
