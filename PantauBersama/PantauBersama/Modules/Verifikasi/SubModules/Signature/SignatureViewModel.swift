//
//  SignatureViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 30/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxCocoa
import RxSwift
import Networking

class SignatureViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let photoI: AnyObserver<UIImage?>
    }
    
    struct Output {
        let photoO: Driver<Void>!
        let errorO: Driver<Error>!
    }
    var navigator: SignatureNavigator
    private let backS = PublishSubject<Void>()
    private let photoS = PublishSubject<UIImage?>()
    
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    
    init(navigator: SignatureNavigator) {
        self.navigator = navigator
        self.navigator.finish = backS
        
        input = Input(backI: backS.asObserver(),
                      photoI: photoS.asObserver())
        
        let photoSelected = photoS
            .flatMapLatest({ (image) -> Driver<BaseResponse<VerificationsResponse>> in
                return NetworkService.instance
                    .requestObject(PantauAuthAPI.putSignature(image: image),
                                   c: BaseResponse<VerificationsResponse>.self)
                    .do(onSuccess: { (response) in
                        print(response.data.user)
                    })
                    .trackError(self.errorTracker)
                    .trackActivity(self.activityIndicator)
                    .asObservable()
                    .asDriverOnErrorJustComplete()
            })
            .flatMapLatest({ _ in navigator.launchSuccess() })
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        
        output = Output(photoO: photoSelected,
                        errorO: self.errorTracker.asDriver())

    }
    
}
