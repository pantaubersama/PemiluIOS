//
//  UpdatesCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Common

protocol UpdatesNavigator {
    func nextTime()
    func update()
}

final class UpdatesCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController
    private let updatesType: TypeUpdates
    
    init(navigationController: UINavigationController, type: TypeUpdates) {
        self.navigationController = navigationController
        self.updatesType = type
    }
    
    override func start() -> Observable<Void> {
        let viewModel = UpdatesViewModel(navigator: self, type: updatesType)
        let viewController = UpdatesView()
        viewController.viewModel = viewModel
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.never()
    }
    
}

extension UpdatesCoordinator: UpdatesNavigator {
    
    func nextTime() {
        UserDefaults.Account.set(true, forKey: .skipVersion)
        UserDefaults.standard.synchronize()
        navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func update() {
        if let url = URL(string: AppContext.instance.infoForKey("AppStoreURL")),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
