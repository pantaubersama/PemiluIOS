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
    let isFromDeeplink: Bool
    let userId: String?
    
    init(navigationController: UINavigationController, isFromDeeplink: Bool, userId: String?) {
        self.navigationController = navigationController
        self.isFromDeeplink = isFromDeeplink
        self.userId = userId
    }
    
    override func start() -> Observable<Void> {
        let viewController = ShareTrendController()
        viewController.isFromDeeplink = isFromDeeplink
        let viewModel = ShareTrendViewModel(navigator: self, isFromDeeplink: isFromDeeplink, userId: userId)
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
        let share = "Hmm.. Ternyata begini kecenderunganku 👀 #PantauBersama \(data.shareURL ?? "")"
//        var objectToShare = [AnyObject]()
//        objectToShare.append(image)
//        objectToShare.append(share as AnyObject)
        let activityViewController = UIActivityViewController(activityItems: [share as NSString, image as UIImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.navigationController.view
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        return Observable.never()
    }
}
