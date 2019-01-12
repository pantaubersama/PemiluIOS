//
//  SosmedViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import TwitterKit

final class SosmedViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
        let itemSelectedI: AnyObserver<IndexPath>
    }
    
    struct Output {
        let itemsO: Driver<[SectionOfSettingData]>
        let doneO: Driver<Void>
        let itemsSelectedO: Driver<Void>
    }
    
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let itemSelectedS = PublishSubject<IndexPath>()
    private var navigator: SosmedNavigator
    
    init(navigator: SosmedNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(
            backI: backS.asObserver(),
            doneI: doneS.asObserver(),
            itemSelectedI: itemSelectedS.asObserver()
        )
        
        let items = Driver.just([
            SectionOfSettingData(header: "Twitter", items: [
                SettingData.twitter
                ]),
            SectionOfSettingData(header: "Facebook", items: [
                SettingData.facebook
                ])
            ])
        
        let done = doneS
            .flatMapLatest({ navigator.launchHome() })
            .asDriverOnErrorJustComplete()
        
        let itemSelected = itemSelectedS
            .withLatestFrom(items) { indexPath, item in
                return item[indexPath.section].items[indexPath.row]
            }
            .flatMapLatest { (type) -> Observable<Void> in
                switch type {
                case .twitter:
                    return Observable.just(TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                        if (session != nil) {
                            print("signed in as \(session?.userName)");
                        } else {
                            print("error: \(error?.localizedDescription)");
                        }
                    })).mapToVoid()
                case .facebook:
                    return Observable.empty()
                default: return Observable.empty()
                }
            }
        
        
        output = Output(
            itemsO: items,
            doneO: done,
            itemsSelectedO: itemSelected.asDriverOnErrorJustComplete())
        
    }
    
}
