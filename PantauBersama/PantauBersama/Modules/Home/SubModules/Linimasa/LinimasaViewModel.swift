//
//  LinimasaViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


protocol ILinimasaViewModelInput {
    var refreshI: AnyObserver<Void> { get }
    var addI: AnyObserver<Void> { get }
    var filterI: AnyObserver<Void> { get }
}

protocol ILinimasaViewModelOutput {
    var addO: Driver<Void>! { get }
    var filterO: Driver<Void>! { get }
}

protocol ILinimasaViewModel {
    var input: ILinimasaViewModelInput { get }
    var output: ILinimasaViewModelOutput { get }
    
    var navigator: LinimasaNavigator! { get }
}

final class LinimasaViewModel: ILinimasaViewModel, ILinimasaViewModelInput, ILinimasaViewModelOutput {
    
    var input: ILinimasaViewModelInput { return self }
    var output: ILinimasaViewModelOutput { return self }
    
    // Input
    var refreshI: AnyObserver<Void>
    var addI: AnyObserver<Void>
    var filterI: AnyObserver<Void>
    // Output
    var addO: Driver<Void>!
    var filterO: Driver<Void>!
    
    private let refreshS = PublishSubject<Void>()
    private let addS = PublishSubject<Void>()
    private let filterS = PublishSubject<Void>()
    
    var navigator: LinimasaNavigator!
    
    init(navigator: LinimasaNavigator) {
        self.navigator = navigator
        
        refreshI = refreshS.asObserver()
        addI = addS.asObserver()
        filterI = filterS.asObserver()
        
        
        addO = addS
            .flatMapLatest({ navigator.launchAddJanji() })
            .asDriverOnErrorJustComplete()
        
        filterO = filterS
            .flatMapLatest({ navigator.launchFilter() })
            .mapToVoid()
            .asDriver(onErrorJustReturn: ())
        
    }
    
    
}
