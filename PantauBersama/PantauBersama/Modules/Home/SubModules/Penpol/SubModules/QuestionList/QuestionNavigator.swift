//
//  AskNavigator.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

//protocol QuestionNavigator {
//    func launchCreateAsk() -> Observable<Void>
//    func shareQuestion(question: String) -> Observable<Void>
//}

import Foundation
import RxSwift
import Networking

protocol IQuestionNavigator: class {
    var navigationController: UINavigationController! { get }
    
    func launchCreateAsk() -> Observable<Void>
    func shareQuestion(question: String) -> Observable<Void>
}

extension IQuestionNavigator where Self: BaseCoordinator<Void> {
    func launchJanjiDetail(data: JanjiPolitik) -> Observable<Void> {
        let janjiDetailCoordinator = DetailJanjiCoordinator(navigationController: navigationController, data: data)
        return coordinate(to: janjiDetailCoordinator)
    }
    
    func shareJanji(data: Any) -> Observable<Void> {
        let activityViewController = UIActivityViewController(activityItems: ["content to be shared" as NSString], applicationActivities: nil)
        self.navigationController.present(activityViewController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func launchBannerInfo(bannerInfo: BannerInfo) -> Observable<Void> {
        let bannerInfoCoordinator = BannerInfoCoordinator(navigationController: self.navigationController, bannerInfo: bannerInfo)
        return coordinate(to: bannerInfoCoordinator)
    }
}
