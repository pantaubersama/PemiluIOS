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

public enum DeepLinkType: String {
    case badge
    case hasilkuis
    case janjipolitik
    case tanya
    case kuis
    case kecenderungan
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
            case "janjipolitik":
                print("janjipolitik")
                if let currentNavigation = UIApplication.topViewController()?.navigationController {
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
                if let currentNavigation = UIApplication.topViewController()?.navigationController {
                    let shareTrendCoordinator = ShareTrendCoordinator(navigationController: currentNavigation)
                    let disposeBag = DisposeBag()
                    shareTrendCoordinator.start()
                        .subscribe()
                        .disposed(by: disposeBag)
                }
            default: break
            }
        }
    }
    
}
