//
//  SearchUserCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

enum SearchUserType {
    case userSymbolic
    case userTwitter
    case `default`
}

final class SearchUserCoordinator: BaseCoordinator<SearchUserResult> {
    
    private let navigationController: UINavigationController
    private let viewController: SearchUserController
    private var type: SearchUserType = .default
    
    init(navigationController: UINavigationController, type: SearchUserType) {
        self.navigationController = navigationController
        self.viewController = SearchUserController()
        self.type = type
    }
    
    override func start() -> Observable<SearchUserResult> {
        let viewModel = SearchUserViewModel(type: type)
        let viewController = SearchUserController()
        viewController.type = type
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return viewModel.output.actionSelected
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] (_) in
                self?.navigationController.dismiss(animated: true, completion: nil)
            })
    }
    
}
