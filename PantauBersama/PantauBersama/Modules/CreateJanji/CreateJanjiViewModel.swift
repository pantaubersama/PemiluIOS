//
//  CreateJanjiViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ICreateJanjiViewModelInput {
    var backI: AnyObserver<Void> { get }
}

protocol ICreateJanjiViewModelOutput {
    
}

protocol ICreateJanjiViewModel {
    var input: ICreateJanjiViewModelInput { get }
    var output: ICreateJanjiViewModelOutput { get }
    
    var navigator: CreateJanjiNavigator! { get }
}

final class CreateJanjiViewModel: ICreateJanjiViewModel, ICreateJanjiViewModelInput, ICreateJanjiViewModelOutput {
    
    var input: ICreateJanjiViewModelInput { return self }
    var output: ICreateJanjiViewModelOutput { return self }
    
    var navigator: CreateJanjiNavigator!
    
    // Input
    var backI: AnyObserver<Void>
    // Output
    
    // Subject
    private let backS = PublishSubject<Void>()
    
    init(navigator: CreateJanjiNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
    }
    
}
