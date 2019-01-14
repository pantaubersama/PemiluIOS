//
//  AskNavigator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

//import Foundation
//import RxSwift
//import Networking

//<<<<<<< HEAD
////protocol QuestionNavigator {
////    func launchCreateAsk() -> Observable<Void>
////    func shareQuestion(question: String) -> Observable<Void>
////}

import Foundation
import RxSwift
import Networking

protocol IQuestionNavigator: class {
//=======
//protocol IQuestionNavigator {
//>>>>>>> [Bhakti][Profile] history user tanya kandidat
    var navigationController: UINavigationController! { get }
    
    func launchCreateAsk() -> Observable<Void>
    func shareQuestion(question: String) -> Observable<Void>
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void>
}

extension IQuestionNavigator where Self: BaseCoordinator<Void> {
//<<<<<<< HEAD
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: janjiDetailCoordinator)
    }
    
//    func shareJanji(data: Any) -> Observable<Void> {
//        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
//=======
    
    func launchCreateAsk() -> Observable<Void> {
        let createAskCoordinator = CreateAskCoordinator(navigationController: self.navigationController)
        return coordinate(to: createAskCoordinator)
    }
    
    func shareQuestion(question: String) -> Observable<Void> {
        // TODO: coordinate to share
        let activityViewController = UIActivityViewController(activityItems: [question as NSString], applicationActivities: nil)
//>>>>>>> [Bhakti][Profile] history user tanya kandidat
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
//<<<<<<< HEAD
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}
//=======
////    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
////        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
////        return coordinate(to: bannerInfoCoordinator)
////    }
//}
//
//>>>>>>> [Bhakti][Profile] history user tanya kandidat
