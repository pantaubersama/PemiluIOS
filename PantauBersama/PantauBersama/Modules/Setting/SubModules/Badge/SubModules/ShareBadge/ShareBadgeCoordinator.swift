//
//  ShareBadgeCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Common

protocol ShareBadgeNavigator {
    var finish: Observable<Void>! { get set }
    func shareBadge(id: String) -> Observable<Void>
}

final class ShareBadgeCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    var id: String
    
    init(navigationController: UINavigationController, id: String) {
        self.navigationController = navigationController
        self.id = id
    }
    
    override func start() -> Observable<Void> {
        let viewController = ShareBadgeController()
        let viewModel = ShareBadgeViewModel(navigator: self, id: id)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}

extension ShareBadgeCoordinator: ShareBadgeNavigator {
    func shareBadge(id: String) -> Observable<Void> {
        let askString = "Yeay! I got the badge 🤘 #PantauBersama \(AppContext.instance.infoForKey("URL_WEB"))/share/badge/\(id)"
        let activityViewController = UIActivityViewController(activityItems: [askString as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.never()
    }
}
