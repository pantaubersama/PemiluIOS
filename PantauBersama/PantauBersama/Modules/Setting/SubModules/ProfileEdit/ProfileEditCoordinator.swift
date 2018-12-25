//
//  ProfileEditCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import UIKit

protocol ProfileEditNavigator {
    
}

class ProfileEditCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let item: SectionOfProfileInfoData
    
    init(navigationController: UINavigationController, item: SectionOfProfileInfoData) {
        self.navigationController = navigationController
        self.item = item
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewModel = ProfileEditViewModel(navigator: self,
                                             item: item)
        let viewController = ProfileEditController()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return Observable.never()
    }
    
}

extension ProfileEditCoordinator: ProfileEditNavigator {
    
    
    
}
