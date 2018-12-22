//
//  SettingViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ISettingViewModelInput {
    var backI: AnyObserver<Void> { get }
}

protocol ISettingViewModelOutput {
    
}

protocol ISettingViewModel {
    var input: ISettingViewModelInput { get }
    var output: ISettingViewModelOutput { get }
    
    var navigator: SettingNavigator! { get }
}

final class SettingViewModel: ISettingViewModel, ISettingViewModelInput, ISettingViewModelOutput {
    
    var input: ISettingViewModelInput { return self }
    var output: ISettingViewModelOutput { return self }
    
    var navigator: SettingNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    
    private let backS = PublishSubject<Void>()
    
    init(navigator: SettingNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
    }
    
}
