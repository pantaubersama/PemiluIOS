//
//  AskNavigator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//


import Foundation
import RxSwift
import Networking
import Common

protocol IQuestionNavigator: class {
    var navigationController: UINavigationController! { get }
    
    func launchCreateAsk(loadCreatedTrigger: AnyObserver<Void>) -> Observable<Void>
    func shareQuestion(question: String) -> Observable<Void>
    func launchQuestionBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
    func launchDetailAsk(data: String) -> Observable<Void>
}

extension IQuestionNavigator where Self: BaseCoordinator<Void> {
    
    func launchCreateAsk(loadCreatedTrigger: AnyObserver<Void>) -> Observable<Void> {
        let createAskCoordinator = CreateAskCoordinator(navigationController: self.navigationController, loadCreatedTrigger: loadCreatedTrigger)
        return coordinate(to: createAskCoordinator)
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let askString = "Kamu setuju pertanyaan ini? Upvote dulu, dong ⬆️ #PantauBersama \(AppContext.instance.infoForKey("URL_WEB"))/share/tanya/\(question)"
        let activityViewController = UIActivityViewController(activityItems: [askString as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchQuestionBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
    
    func launchDetailAsk(data: String) -> Observable<Void> {
        let detailAskCoordinator = DetailAskCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: detailAskCoordinator)
    }
}
