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
    func shareTrendResult(image: UIImage,data: TrendResponse) -> Observable<Void>
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
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        return finish
            .asObservable()
            .take(1)
    }
    
}


extension ShareTrendCoordinator: ShareTrendNavigator {
    func shareTrendResult(image: UIImage, data: TrendResponse) -> Observable<Void> {
        let share = "Hmm.. Ternyata begini kecenderunganku 👀 #PantauBersama \(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/kecenderungan/\(data.user.id)"
//        var objectToShare = [AnyObject]()
//        objectToShare.append(image)
//        objectToShare.append(share as AnyObject)
        let activityViewController = UIActivityViewController(activityItems: [image, share as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.navigationController.view
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.never()
    }
}
