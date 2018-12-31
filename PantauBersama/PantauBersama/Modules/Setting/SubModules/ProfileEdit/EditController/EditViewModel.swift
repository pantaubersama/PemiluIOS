//
//  EditViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Networking

final class EditViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backTrigger: AnyObserver<Void>
        let doneTrigger: AnyObserver<Void>
        let inputTrigger: [BehaviorSubject<String?>]
    }
    
    struct Output {
        let items: Driver<[ICellConfigurator]>
        let title: Driver<String>
        let actionSelected: Driver<Void>
        let errorTracker: Driver<Error>
        let isEnabled: Driver<Bool>
    }
    
    private var navigator: EditNavigator
    private let item: SectionOfProfileInfoData
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    
    init(navigator: EditNavigator, item: SectionOfProfileInfoData) {
        self.navigator = navigator
        self.navigator.finish = backS
        self.item = item
        
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        // MARK
        // Array textField
        let inputText = item.items
            .map { (field) -> BehaviorSubject<String?> in
                return BehaviorSubject<String?>(value: field.value)
        }
        
        
        
        
        // MARK
        // Input
        input = Input(backTrigger: backS.asObserver(),
                      doneTrigger: doneS.asObserver(),
                      inputTrigger: inputText)
        
        // MARK
        // Build cell for TableView
        let items = item.items
            .enumerated()
            .map { (arg) -> ICellConfigurator in
                let (index, item) = arg
                return TextViewCellConfigured(item: TextViewCell.Input(viewModel: self, index: index, data: item))
        }
        
        let generator = inputText
            .enumerated()
            .map { (offset, element) -> Observable<String?> in
                return element
        }
        
        let parameters = Observable.combineLatest(generator)
            .map { (params) -> [String: Any] in
                return params.enumerated()
                    .reduce(into: [:], { (old, arg) in
                        let (offset, text) = arg
                        switch item.items[offset].fieldType {
                        case .gender:
                            return old[item.items[offset].parameter] =
                             Gender.index(title: text)
                        default:
                            return old[item.items[offset].parameter] = text
                        }
                    })
                    .filter({ !$0.key.isEmpty })
        }
        
        let doneAction = doneS
            .withLatestFrom(parameters)
            .flatMapLatest ({ (parameters) -> Observable<BaseResponse<UserResponse>> in
                var parameters = parameters
                print(parameters)
                switch item.header {
                    case .editProfile:
                        return NetworkService.instance
                        .requestObject(PantauAuthAPI.putMe(parameters: parameters), c: BaseResponse<UserResponse>.self)
                        .trackError(errorTracker)
                        .trackActivity(activityIndicator)
                        .catchErrorJustComplete()
                case .editPassword:
                    return NetworkService.instance
                    .requestObject(PantauAuthAPI.putMe(parameters: parameters), c: BaseResponse<UserResponse>.self)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .catchErrorJustComplete()
                case .editDataLapor:
                    return NetworkService.instance
                        .requestObject(PantauAuthAPI.putInformants(parameters: parameters), c: BaseResponse<UserResponse>.self)
                        .trackError(errorTracker)
                        .trackActivity(activityIndicator)
                        .catchErrorJustComplete()
                }
            })
            .do(onNext: { (response) in
                let data = response.data
                AppState.saveMe(data)
            })
            .mapToVoid()
        
        let actionSelected = doneAction
        
        output = Output(items: Driver.just(items),
                        title: Driver.just(item.header.title),
                        actionSelected: actionSelected.asDriverOnErrorJustComplete(),
                        errorTracker: errorTracker.asDriver(),
                        isEnabled: activityIndicator.asDriver())
        
    }
    
}
