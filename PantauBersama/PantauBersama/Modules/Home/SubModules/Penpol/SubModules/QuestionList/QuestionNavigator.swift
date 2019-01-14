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

protocol IQuestionNavigator: class {
    var navigationController: UINavigationController! { get }
    
    func launchCreateAsk() -> Observable<Void>
    func shareQuestion(question: String) -> Observable<Void>
    func launchQuestionBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
}

extension IQuestionNavigator where Self: BaseCoordinator<Void> {
    
    func launchCreateAsk() -> Observable<Void> {
        let createAskCoordinator = CreateAskCoordinator(navigationController: self.navigationController)
        return coordinate(to: createAskCoordinator)
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: [question as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchQuestionBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}
