//
//  ProfileEditViewModel.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common

class ProfileEditViewModel: ViewModelType {
    
    var input: Input
    var output: Output!
    
    struct Input {
        let backI: AnyObserver<Void>
        let doneI: AnyObserver<Void>
    }
    
    
    struct Output {
        let items: Driver<[ICellConfigurator]>
        let title: Driver<String>
    }
    
    private let item: SectionOfProfileInfoData
    private let navigator: ProfileEditNavigator
    private let backS = PublishSubject<Void>()
    private let doneS = PublishSubject<Void>()
    
    init(navigator: ProfileEditNavigator, item: SectionOfProfileInfoData) {
        self.navigator = navigator
        self.item = item
        
        // MARK: Input
        input = Input(backI: backS.asObserver(),
                      doneI: doneS.asObserver())
        
        // MARK: Build cell for UITableView
        let items = item.items
            .enumerated()
            .map { (index, item) -> ICellConfigurator in
                switch item.fieldType {
                case .text, .number, .password, .username:
                    return TextViewCellConfigured(item: TextViewCell.Input(viewModel: self, index: index, data: item))
                case .date:
                    return DateViewCellConfigured(item: DateViewCell.Input(viewModel: self, index: index, data: item))
                }
            }
        
        // MARK: Output
        output = Output(items: Driver.just(items),
                        title: Driver.just(item.header.title))
    }
    
}
