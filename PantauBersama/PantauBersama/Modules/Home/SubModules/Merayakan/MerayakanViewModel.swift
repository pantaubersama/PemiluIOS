//
//  RekapViewModel.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Networking
import Common

final class MerayakanViewModel: ViewModelType {
    
    var input: Input
    var output: Output!

    struct Input {
        let searchTrigger: AnyObserver<Void>
        let profileTrigger: AnyObserver<Void>
        let notifTrigger: AnyObserver<Void>
        let catatanTrigger: AnyObserver<Void>
    }
    
    struct Output {
        let searchSelected: Driver<Void>
        let profileSelected: Driver<Void>
        let notifSelected: Driver<Void>
        let catatanSelected: Driver<Void>
    }
    
    let navigator: MerayakanNavigator
    
    private let searchS = PublishSubject<Void>()
    private let profileS = PublishSubject<Void>()
    private let notifS = PublishSubject<Void>()
    private let catatanS = PublishSubject<Void>()
    
    init(navigator: MerayakanNavigator) {
        self.navigator = navigator
    
        input = Input(
            searchTrigger: searchS.asObserver(),
            profileTrigger: profileS.asObserver(),
            notifTrigger: notifS.asObserver(),
            catatanTrigger: catatanS.asObserver())
        
        let search = searchS
            .flatMap({ self.navigator.launchSearch() })
            .asDriverOnErrorJustComplete()
        
        let profile = profileS
            .flatMap({ self.navigator.launchProfile() })
            .asDriverOnErrorJustComplete()
        
        let notif = notifS
            .flatMap({ self.navigator.launchNotifications() })
            .asDriverOnErrorJustComplete()
        
        let catatan = catatanS
            .flatMap({ self.navigator.launchNote() })
            .asDriverOnErrorJustComplete()
        
        output = Output(
            searchSelected: search,
            profileSelected: profile,
            notifSelected: notif,
            catatanSelected: catatan)
    }
}
