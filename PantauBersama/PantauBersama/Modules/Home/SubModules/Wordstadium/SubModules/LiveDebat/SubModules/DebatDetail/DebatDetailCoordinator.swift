//
//  DebatDetailCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 18/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

protocol DebatDetailNavigator {
    func back() -> Observable<Void>
}

class DebatDetailCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let challenge: Challenge
    
    init(navigationController: UINavigationController, challenge: Challenge) {
        self.navigationController = navigationController
        self.challenge = challenge
    }
    
    override func start() -> Observable<Void> {
        let viewController = DebatDetailController()
        let viewModel = DebatDetailViewModel(navigator: self, challenge: challenge)
        viewController.viewModel = viewModel
        
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.never()
    }
}

extension DebatDetailCoordinator: DebatDetailNavigator {
    func back() -> Observable<Void> {
        self.navigationController.dismiss(animated: true
            , completion: nil)
        return Observable.never()
    }
}
