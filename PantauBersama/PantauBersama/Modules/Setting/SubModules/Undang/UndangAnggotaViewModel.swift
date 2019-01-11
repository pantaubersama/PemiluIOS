//
//  UndangAnggotaViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 26/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

class UndangAnggotaViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let undangTrigger: AnyObserver<Void>
        let switchTrigger: BehaviorSubject<Bool>
        let switchLabelTrigger: AnyObserver<String>
        let emailTrigger: AnyObserver<String>
    }
    
    struct Output {
        let createSelected: Driver<Void>
        let switchSelected: Driver<String>
        let switchLabelSelected: Driver<String>
        let userData: Driver<User>
        let enable: Driver<Bool>
    }
    
    private let undangSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let switchSubject = BehaviorSubject<Bool>(value: false)
    private let switchLabelSubject = PublishSubject<String>()
    private let emailSubject = PublishSubject<String>()
    private let emailInput = PublishSubject<Void>()
    
    var navigator: UndangAnggotaNavigator
    private let data: User
    
    init(navigator: UndangAnggotaNavigator, data: User) {
        self.navigator = navigator
        self.navigator.finish = backSubject
        self.data = data
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        input = Input(backTrigger: backSubject.asObserver(),
                      undangTrigger: undangSubject.asObserver(),
                      switchTrigger: switchSubject.asObserver(),
                      switchLabelTrigger: switchLabelSubject.asObserver(),
                      emailTrigger: emailSubject.asObserver())
        
        let magicLink = switchSubject
            .flatMapLatest { (value) -> Observable<String> in
                print(value)
                return NetworkService.instance
                    .requestObject(PantauAuthAPI
                        .clusterMagicLink(id: data.cluster?.id ?? "",
                                          enable: value),
                                   c: BaseResponse<SingleCluster>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asObservable()
                    .map({ $0.data.cluster.magicLink ?? "" })
            }
        
        let label = switchLabelSubject
            .asDriverOnErrorJustComplete()
        
        let undangEmail = undangSubject
            .withLatestFrom(emailSubject)
            .flatMapLatest { (email) -> Observable<Void> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.clusterInvite(emails: email)
                        , c: BaseResponses<ClusterInvite>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asObservable()
                    .mapToVoid()
            }.flatMapLatest({ navigator.success() })
            .catchErrorJustComplete()
        
        
        let enable = emailSubject
            .map({ (email) -> Bool in
                return email.isValidEmail()
                || email.contains(",") // regex multiple emails, need improve later
            })
            .startWith(false)
            .asDriverOnErrorJustComplete()
        
        
        output = Output(createSelected: undangEmail.asDriverOnErrorJustComplete(),
                        switchSelected: magicLink.asDriverOnErrorJustComplete(),
                        switchLabelSelected: label,
                        userData: Driver.just(data),
                        enable: enable)
    }
    
}
