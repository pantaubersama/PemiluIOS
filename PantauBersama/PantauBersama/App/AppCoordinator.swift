//
//  AppCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//


import UIKit
import RxSwift
import Common
import Networking

class AppCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.window.backgroundColor = UIColor.white
    }
    
    override func start() -> Observable<CoordinationResult> {
        let user: Data? = UserDefaults.Account.get(forKey: .userData)
        if user != nil {
            let homeCoordinator = HomeCoordinator(window: self.window)
            return self.coordinate(to: homeCoordinator)
        } else {
            KeychainService.remove(type: NetworkKeychainKind.token)
            KeychainService.remove(type: NetworkKeychainKind.refreshToken)
            let onBoardingCoordinator = OnboardingCoordinator(window: self.window)
            return coordinate(to: onBoardingCoordinator)
        }
    }
    
}
