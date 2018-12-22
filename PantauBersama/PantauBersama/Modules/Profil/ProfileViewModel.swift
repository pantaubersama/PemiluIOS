//
//  ProfileViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol IProfileViewModelInput {
    var backI: AnyObserver<Void> { get }
    var settingI: AnyObserver<Void> { get }
}

protocol IProfileViewModelOutput {
    var settingO: Driver<Void>! { get }
}

protocol IProfileViewModel {
    var input: IProfileViewModelInput { get }
    var output: IProfileViewModelOutput { get }
    
    var navigator: ProfileNavigator! { get }
}

final class ProfileViewModel: IProfileViewModel, IProfileViewModelInput, IProfileViewModelOutput {
    
    var input: IProfileViewModelInput { return self }
    var output: IProfileViewModelOutput { return self }
    
    var navigator: ProfileNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    var settingI: AnyObserver<Void>
    
    // Output
    var settingO: Driver<Void>!
    
    private let backS = PublishSubject<Void>()
    private let settingS = PublishSubject<Void>()
    
    init(navigator: ProfileNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
        
        settingI = settingS.asObserver()
        
        let setting = settingS
            .flatMapLatest({ navigator.launchSetting() })
            .asDriver(onErrorJustReturn: ())
        
        settingO = setting
    }
    
}
