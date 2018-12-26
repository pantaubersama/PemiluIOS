//
//  SettingCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift

protocol SettingNavigator {
    var finish: Observable<Void>! { get set }
    func launchProfileEdit() -> Observable<Void>
    func launchSignOut() -> Observable<Void>
    func launchBadge() -> Observable<Void>
    func launchVerifikasi(isVerified: Bool) -> Observable<Void>
}

final class SettingCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinationResult> {
        let viewController = SettingController()
        let viewModel = SettingViewModel(navigator: self)
        viewController.viewModel = viewModel
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension SettingCoordinator: SettingNavigator {
    func launchProfileEdit() -> Observable<Void> {
        let profileEditCoordinator = ProfileEditCoordinator(navigationController: navigationController)
        return coordinate(to: profileEditCoordinator)
    }
    
    func launchSignOut() -> Observable<Void> {
        let logoutCoordinator = LogoutCoordinator(navigationController: navigationController)
        return coordinate(to: logoutCoordinator)
            .filter({ $0 == .logout })
            .mapToVoid()
            .flatMap({ [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.launchOnboarding()
            })
        
    }
    
    func launchOnboarding() -> Observable<Void> {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            let appCoordinator = AppCoordinator(window: window)
            return self.coordinate(to: appCoordinator)
        }
        return Observable.empty()
    }
    
    func launchBadge() -> Observable<Void> {
        let badgeCoordinator = BadgeCoordinator(navigationController: navigationController)
        return coordinate(to: badgeCoordinator)
    }
    
    func launchVerifikasi(isVerified: Bool) -> Observable<Void> {
        let verifikasiCoordinator = IdentitasCoordinator(navigationController: navigationController)
        return coordinate(to: verifikasiCoordinator)
    }
}
