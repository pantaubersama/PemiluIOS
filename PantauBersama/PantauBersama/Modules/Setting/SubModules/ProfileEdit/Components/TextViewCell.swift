//
//  TextViewCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

typealias TextViewCellConfigured = CellConfigurator<TextViewCell, TextViewCell.Input>

class TextViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var textField: TextField!
    
    var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension TextViewCell: IReusableCell {
    struct Input {
        let viewModel: ProfileEditViewModel
        let data: ProfileInfoField
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        let pickerView = UIPickerView()
        
        titleLabel.text = item.data.key.title
        textField.text = item.data.value
        print(item.data.key)
        switch item.data.key {
        case .nama:
            textField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: item.viewModel.input.nameI)
                .disposed(by: bag)
        case .username:
            textField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: item.viewModel.input.usernameI)
                .disposed(by: bag)
        case .address:
            textField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: item.viewModel.input.addressI)
                .disposed(by: bag)
        case .about:
            textField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: item.viewModel.input.aboutI)
                .disposed(by: bag)
        case .pekerjaan:
            textField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: item.viewModel.input.occupationI)
                .disposed(by: bag)
        case .gender:
            let data = [
                Gender.female,
                Gender.male
            ]
            Observable.just(data)
                .bind(to: pickerView.rx.itemTitles) { (row, element) in
                    return element.title
                }
                .disposed(by: bag)
            
//            pickerView.rx.modelSelected(Gender.self)
//                .flatMapLatest({ $0.first.map({ Observable.just($0) }) ?? Observable.empty() })
//                        .map({ $0.title })
//                        .bind(to: item.viewModel.input.inputTrigger[item.data.key.rawValue])
//                        .disposed(by: bag)
        
            textField.inputView = pickerView
        disposeBag = bag
        default: break
        }
        
    }
}
