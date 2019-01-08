//
//  ClusterSearchCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

//import Foundation
//import RxSwift
//
//final class ClusterSearchCoordinator: BaseCoordinator<ClusterResult> {
//    private let navigationController: UINavigationController
//    
//    init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//    }
//    
//    override func start() -> Observable<ClusterResult> {
//        let viewController = ClusterSearchController()
//        let viewModel = ClusterSearchViewModel()
//        viewController.viewModel = viewModel
//        navigationController.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
//        return viewModel.output.result
//            .asObservable()
//            .take(1)
//            .do(onNext: { [weak self] (_) in
//                self?.navigationController.dismiss(animated: true, completion: nil)
//            })
//    }
//}
