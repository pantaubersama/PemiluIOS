//
//  DetailTPSCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa

protocol DetailTPSNavigator {
    func launchDetailTPSPresiden() -> Observable<Void>
    func launchDetailTPSDPRI() -> Observable<Void>
    func launchDetailTPSDPD() -> Observable<Void>
    func launchDetailTPSDPRDKab() -> Observable<Void>
    func launchDetailTPSDPRDProv() -> Observable<Void>
}

class DetailTPSCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = DetailTPSController()
        let viewModel = DetailTPSViewModel(navigator: self)
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: true)
        
        return Observable.never()
    }
}

extension DetailTPSCoordinator: DetailTPSNavigator {
    func launchDetailTPSPresiden() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchDetailTPSDPRI() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchDetailTPSDPD() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchDetailTPSDPRDKab() -> Observable<Void> {
        return Observable.never()
    }
    
    func launchDetailTPSDPRDProv() -> Observable<Void> {
        return Observable.never()
    }
    
    
}

