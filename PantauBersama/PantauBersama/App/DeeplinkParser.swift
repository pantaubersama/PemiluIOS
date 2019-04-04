//
//  DeeplinkParser.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Networking

public enum DeepLinkType: String {
    case badge
    case hasilkuis
    case janjipolitik
    case tanya
    case kuis
    case kecenderungan
    case wordstadium
}

public class DeeplinkParser {
    
    static let shared = DeeplinkParser()
    
    public init() { }
    
    func parseDeepLink(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            // MARK
            // GET PATH Components
            var pathComponents = components.path.components(separatedBy: "/")
            // remove first components because unused
            pathComponents.removeFirst()
            let idPath = pathComponents.last
            // identiifier components must after array [0]
            let identifier = pathComponents[1]
            print("identitifier: \(identifier)")
            switch identifier {
            case "badge":
                if let id = idPath {
                    if let currentNavigation = UIApplication.topViewController()?.navigationController {
                        let shareBadgeCoordinator = ShareBadgeCoordinator(navigationController: currentNavigation, id: id)
                        let disposeBag = DisposeBag()
                        shareBadgeCoordinator.start()
                            .subscribe()
                            .disposed(by: disposeBag)
                    }
                }
            case "hasilkuis":
               print("received hasil kuis")
               if let id = idPath {
                    if let currentNavigation = UIApplication.topViewController()?.navigationController {
                        let quizResultCoordinator = QuizResultCoordinator(navigationController: currentNavigation, quiz: nil, isFromDeeplink: true, participationURL: id)
                        let disposeBag = DisposeBag()
                        quizResultCoordinator.start()
                            .subscribe()
                            .disposed(by: disposeBag)
                    }
                }
            case "janjipolitik":
                print("janjipolitik")
                if let id = idPath {
                    if let currentNavigation = UIApplication.topViewController()?.navigationController {
                        let disposeBag = DisposeBag()
                        let detailJanji = DetailJanjiCoordinator(navigationController: currentNavigation, data: id)
                        detailJanji.start()
                            .subscribe()
                            .disposed(by: disposeBag)
                    }
                }
            case "tanya":
                print("tanya")
                if let id = idPath {
                    if let currentNavigation = UIApplication.topViewController()?.navigationController {
                        let tanyaCoordinator = DetailAskCoordinator(navigationController: currentNavigation, data: id, isFromNotif: true)
                        let disposeBag = DisposeBag()
                        tanyaCoordinator.start()
                            .subscribe()
                            .disposed(by: disposeBag)
                    }
                }
            case "kuis":
                print("kuis")
                if let appWindow = UIApplication.shared.keyWindow {
                    let homeCoordinator = HomeCoordinator(window: appWindow, isNewQuiz: true)
                    
                    let disposeBag = DisposeBag()
                    
                    homeCoordinator.start()
                        .subscribe()
                        .disposed(by: disposeBag)
                }
            case "kecenderungan":
                print("trend")
                if let id = idPath {
                    if let currentNavigation = UIApplication.topViewController()?.navigationController {
                        let shareTrendCoordinator = ShareTrendCoordinator(navigationController: currentNavigation, isFromDeeplink: true, userId: id)
                        let disposeBag = DisposeBag()
                        shareTrendCoordinator.start()
                            .subscribe()
                            .disposed(by: disposeBag)
                    }
                }
            case "wordstadium":
                print("Wordstadium")
                if let id = idPath {
                    let disposeBag = DisposeBag()
                    NetworkService.instance
                        .requestObject(WordstadiumAPI.getChallengeDetail(id: id),
                                       c: BaseResponse<CreateChallengeResponse>.self)
                        .map({ $0.data.challenge })
                        .subscribe(onSuccess: { (response) in
                            if let currentNavigation = UIApplication.topViewController()?.navigationController {
                                if response.progress == .liveNow {
                                    let liveDetail = LiveDebatCoordinator(navigationController: currentNavigation, challenge: response)
                                    liveDetail.start()
                                        .subscribe()
                                        .disposed(by: disposeBag)
                                } else {
                                    let challengeDetail = ChallengeCoordinator(navigationController: currentNavigation, data: response)
                                    challengeDetail.start()
                                        .subscribe()
                                        .disposed(by: disposeBag)
                                }
                            }
                        })
                        .disposed(by: disposeBag)
                }
            default: break
            }
        }
    }
    
}
