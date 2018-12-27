//
//  OnboardingCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Common

protocol OnboardingNavigator {
    func signIn() -> Observable<Void>
    func bypass() -> Observable<Void>
}

class OnboardingCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    override func start() -> Observable<Void> {
        let viewController = OnboardingViewController()
        let viewModel = OnboardingViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.isNavigationBarHidden = true
        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return Observable.never()
    }
}

extension OnboardingCoordinator: OnboardingNavigator {
    
    func signIn() -> Observable<Void> {
        let urlString = "\(AppContext.instance.infoForKey("DOMAIN_SYMBOLIC"))/oauth/authorize?client_id=\(AppContext.instance.infoForKey("CLIENT_ID"))&response_type=code&redirect_uri=\(AppContext.instance.infoForKey("REDIRECT_URI"))&scope="
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
        return Observable.just(())
    }
    
    func bypass() -> Observable<Void> {
        let homeCoordinator = HomeCoordinator(window: self.window)
        return coordinate(to: homeCoordinator)
    }
    
    
}
