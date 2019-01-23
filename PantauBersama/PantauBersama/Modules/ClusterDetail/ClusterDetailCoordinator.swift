//
//  ClusterDetailCoordinator.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

protocol ClusterDetailNavigator {
    func finish() -> Observable<Void>
}

class ClusterDetailCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let cluster: ClusterDetail
    
    init(navigationController: UINavigationController, cluster: ClusterDetail) {
        self.navigationController = navigationController
        self.cluster = cluster
    }
    override func start() -> Observable<Void> {
        let viewModel = ClusterDetailViewModel(cluster: self.cluster, navigator: self)
        let viewController = ClusterDetailController()
        viewController.viewModel = viewModel
        
        navigationController.present(viewController, animated: true, completion: nil)
        return Observable.never()
    }
}

extension ClusterDetailCoordinator: ClusterDetailNavigator {
    func finish() -> Observable<Void> {
        self.navigationController.dismiss(animated: true, completion: nil)
        return Observable.never()
    }
}
