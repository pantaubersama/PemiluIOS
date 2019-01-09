//
//  AddKategoriViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 09/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Networking

enum AddKategoriResult {
    case cancel
    case ok
}

final class AddKategoriViewModel: ViewModelType {
    
    let input: Input
    let output: Output!
    
    struct Input {
        let sendI: AnyObserver<Void>
        let cancelI: AnyObserver<Void>
        let textI: AnyObserver<String>
        let viewWillAppearI: AnyObserver<Void>
    }
    
    struct Output {
        let actionSelected: Driver<Void>
        let isEnabled: Driver<Bool>
        let cancelO: Driver<Void>
    }
    
    private let cancelSubject = PublishSubject<Void>()
    private let sendSubject = PublishSubject<Void>()
    private let titleS = PublishSubject<String>()
    private let viewWillAppearS = PublishSubject<Void>()
    private var navigator: AddKategoriNavigator

    init(navigator: AddKategoriNavigator) {
        self.navigator = navigator
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        input = Input(sendI: sendSubject.asObserver(),
                      cancelI: cancelSubject.asObserver(),
                      textI: titleS.asObserver(),
                      viewWillAppearI: viewWillAppearS.asObserver())
        
        let sendSelected = sendSubject
            .withLatestFrom(titleS)
            .flatMapLatest { (s) -> Observable<BaseResponse<SingleCategory>> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.createCategories(t: s),
                                   c: BaseResponse<SingleCategory>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
            }.mapToVoid()
    
        let send = sendSelected
            .flatMapLatest({ navigator.back() })
        
        let cancel = cancelSubject
            .flatMapLatest({ navigator.back() })
        
        
        let isEnabled = titleS
            .map { (s) -> Bool in
                return s.count > 0
            }
            .startWith(false)
            .asDriverOnErrorJustComplete()
        
        output = Output(actionSelected: send.asDriverOnErrorJustComplete(),
                        isEnabled: isEnabled,
                        cancelO: cancel.asDriverOnErrorJustComplete())
    }
    
}
