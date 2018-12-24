//
//  IdentitasViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa

protocol IIdentitasViewModelInput {
    var backI: AnyObserver<Void> { get }
}

protocol IIdentitasViewModelOutput {
    
}

protocol IIdentitasViewModel {
    var input: IIdentitasViewModelInput { get }
    var output: IIdentitasViewModelOutput { get }
}

final class IdentitasViewModel: IIdentitasViewModelInput, IIdentitasViewModelOutput, IIdentitasViewModel {
    
    var input: IIdentitasViewModelInput { return self }
    var output: IIdentitasViewModelOutput { return self }
    
    var navigator: IdentitasNavigator!
    
    var backI: AnyObserver<Void>
    
    private let backS = PublishSubject<Void>()
    
    init(navigator: IdentitasNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        backI = backS.asObserver()
    }
}
