//
//  ProfileCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol ProfileNavigator {
    var finish: Observable<Void>! { get set }
    
    func launchSetting() -> Observable<Void>
}


final class ProfileCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = ProfileController()
        let viewModel = ProfileViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
}

extension ProfileCoordinator: ProfileNavigator {
    
    func launchSetting() -> Observable<Void> {
        let settingCoordinator = SettingCoordinator(navigationController: navigationController)
        return coordinate(to: settingCoordinator)
    }
    
}
