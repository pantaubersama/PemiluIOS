//
//  SelfIdentitasViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 29/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking

protocol ISelfIdentitasViewModelInput {
    var backI: AnyObserver<Void> { get }
    var photoI: AnyObserver<Void> { get }
}

protocol ISelfIdentitasViewModelOutput {

}

protocol ISelfIdentitasViewModel {
    var input: ISelfIdentitasViewModelInput { get }
    var output: ISelfIdentitasViewModelOutput { get }
}

final class SelfIdentitasViewModel: ISelfIdentitasViewModelInput, ISelfIdentitasViewModelOutput, ISelfIdentitasViewModel {
    
    var input: ISelfIdentitasViewModelInput { return self }
    var output: ISelfIdentitasViewModelOutput { return self }
    var navigator: SelfIdentitasNavigator!
    
    // MARK: Input
    var backI: AnyObserver<Void>
    var photoI: AnyObserver<Void>
    
    // MARK: Output
    
    
    // MARK: Subject
    private let backS = PublishSubject<Void>()
    private let photoS = PublishSubject<Void>()
    
    init(navigator: SelfIdentitasNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        photoI = photoS.asObserver()
    }
}
