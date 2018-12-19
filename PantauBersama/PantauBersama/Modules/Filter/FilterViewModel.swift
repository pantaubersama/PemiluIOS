//
//  FilterViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa


protocol IFilterViewModelInput {
    var backI: AnyObserver<Void> { get }
}

protocol IFilterViewModelOutput {
    var backO: Driver<Void>! { get }
}

protocol IFilterViewModel {
    var input: IFilterViewModelInput { get }
    var output: IFilterViewModelOutput { get }
    

}

final class FilterViewModel: IFilterViewModel, IFilterViewModelInput, IFilterViewModelOutput {

    var input: IFilterViewModelInput { return self }
    var output: IFilterViewModelOutput { return self }
    
    var navigator: FilterNavigator!
    //Input
    var backI: AnyObserver<Void>
    // Output
    var backO: Driver<Void>!
    
    private let backS = PublishSubject<Void>()
    
    init(navigator: FilterNavigator) {
        self.navigator = navigator
        
        backI = backS.asObserver()
        
    }
}
