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
    var photoI: AnyObserver<UIImage?> { get }
}

protocol ISelfIdentitasViewModelOutput {
    var photoO: Driver<Void>! { get }
    var errorTrackerO: Driver<Error>! { get }
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
    var photoI: AnyObserver<UIImage?>
    
    // MARK: Output
    var photoO: Driver<Void>!
    var errorTrackerO: Driver<Error>!
    
    // MARK: Subject
    private let backS = PublishSubject<Void>()
    private let photoS = PublishSubject<UIImage?>()
    private let doneS = PublishSubject<Void>()
    
    init(navigator: SelfIdentitasNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        photoI = photoS.asObserver()
        
        let photoSelected = photoS
            .flatMapLatest({ (image) -> Driver<BaseResponse<VerificationsResponse>> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.putSelfieKTP(image: image),
                                   c: BaseResponse<VerificationsResponse>.self)
                    .do(onSuccess: { (response) in
                        print(response.data.user)
                    })
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asObservable()
                    .asDriverOnErrorJustComplete()
            })
            .flatMapLatest({ _ in navigator.launchKTP() })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        // MARK
        // Output
        photoO = photoSelected
        errorTrackerO = errorTracker.asDriver()
    }
    
}
