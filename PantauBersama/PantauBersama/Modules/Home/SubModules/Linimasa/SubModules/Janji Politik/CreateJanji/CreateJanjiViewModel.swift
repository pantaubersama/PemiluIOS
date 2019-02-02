//
//  CreateJanjiViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Networking
import Common

enum SelectionResult {
    case cancel
    case result(CreateJanjiPolitikResponse)
}

protocol ICreateJanjiViewModelInput {
    var backI: AnyObserver<Void> { get }
    var doneI: AnyObserver<Void> { get }
    var titleI: AnyObserver<String> { get }
    var bodyI: AnyObserver<String> { get }
    var viewWillAppearI: AnyObserver<Void> { get }
    var imageI: AnyObserver<UIImage?> { get }
}

protocol ICreateJanjiViewModelOutput {
    var userDataO: Driver<UserResponse>! { get }
    var enableO: Driver<Bool>! { get }
    var errorO: Driver<Error>! { get }
    var actionO: Driver<SelectionResult>! { get }
}

protocol ICreateJanjiViewModel {
    var input: ICreateJanjiViewModelInput { get }
    var output: ICreateJanjiViewModelOutput { get }
}

final class CreateJanjiViewModel: ICreateJanjiViewModel, ICreateJanjiViewModelInput, ICreateJanjiViewModelOutput {
    
    var input: ICreateJanjiViewModelInput { return self }
    var output: ICreateJanjiViewModelOutput { return self }
    
    // Input
    var backI: AnyObserver<Void>
    var doneI: AnyObserver<Void>
    var titleI: AnyObserver<String>
    var bodyI: AnyObserver<String>
    var viewWillAppearI: AnyObserver<Void>
    var imageI: AnyObserver<UIImage?>
    
    // Output
    var userDataO: Driver<UserResponse>!
    var enableO: Driver<Bool>!
    var errorO: Driver<Error>!
    var actionO: Driver<SelectionResult>!
    
    // Subject
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    private let titleS = PublishSubject<String>()
    private let bodyS = PublishSubject<String>()
    private let viewWillAppearS = PublishSubject<Void>()
    private let imageS = PublishSubject<UIImage?>()
    
    init() {
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        backI = backS.asObserver()
        doneI = doneS.asObserver()
        titleI = titleS.asObserver()
        bodyI = bodyS.asObserver()
        viewWillAppearI = viewWillAppearS.asObserver()
        imageI = imageS.asObserver()
        
        // MARK
        // Get user data from cloud and Local
        let local: Observable<UserResponse> = AppState.local(key: .me)
        let cloud = NetworkService.instance.requestObject(
            PantauAuthAPI.me,
            c: BaseResponse<UserResponse>.self)
            .map({ $0.data })
            .do(onSuccess: { (response) in
                AppState.saveMe(response)
            }, onError: { (e) in
                print(e.localizedDescription)
            })
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
            .asObservable()
            .catchErrorJustComplete()
        
        let userData = viewWillAppearS
            .flatMapLatest({ Observable.merge(local, cloud)})
    
        
        let enablePost = Observable.combineLatest(titleS, bodyS)
            .map { (title, body) -> Bool in
                return title.count > 0 && body.count > 0 && !body.containsInsensitive("Berikan deskripsi atau detil lebih lanjut terkait Janji Politik yang akan disampaikan di kolom ini.")
            }
            .startWith(false)
        
        let done = doneS
            .withLatestFrom(Observable.combineLatest(titleS, bodyS, imageS.startWith(nil)))
            .flatMapLatest({(title, body, image) in
                return NetworkService.instance.requestObject(
                    LinimasaAPI.createJanjiPolitiks(
                        title: title,
                        body: body,
                        image: image),
                    c: BaseResponse<CreateJanjiPolitikResponse>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
            })
            .map { (response) in
                SelectionResult.result(response.data)
            }
        
     
        let dismisSelected = backS
            .map({ SelectionResult.cancel })
        
        let actionSelected = Observable.merge(dismisSelected, done)
            .take(1)
            .asDriverOnErrorJustComplete()
        
        userDataO = userData.asDriverOnErrorJustComplete()
        errorO = errorTracker.asDriver()
        enableO = enablePost.asDriverOnErrorJustComplete()
        actionO = actionSelected
    }
    
}
