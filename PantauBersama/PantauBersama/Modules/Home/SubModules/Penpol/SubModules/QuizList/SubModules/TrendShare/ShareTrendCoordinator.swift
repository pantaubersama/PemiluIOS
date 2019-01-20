//
//  ShareTrendCoordinator.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import Networking
import Common

protocol ShareTrendNavigator {
    var finish: Observable<Void>! { get set }
    func shareTrendResult(data: TrendResponse) -> Observable<Void>
}

final class ShareTrendCoordinator: BaseCoordinator<Void> {
    
    private let navigationController: UINavigationController!
    var finish: Observable<Void>!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewController = ShareTrendController()
        let viewModel = ShareTrendViewModel(navigator: self)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        return finish.do(onNext: { [weak self] (_) in
            self?.navigationController.popViewController(animated: true)
        })
    }
    
}


extension ShareTrendCoordinator: ShareTrendNavigator {
    func shareTrendResult(data: TrendResponse) -> Observable<Void> {
        let share = "Hmm.. Ternyataa 👀\(AppContext.instance.infoForKey("URL_API_PEMILU"))/share/badge/\(data.user.id)"
        let activityViewController = UIActivityViewController(activityItems: [share as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.never()
    }
}
