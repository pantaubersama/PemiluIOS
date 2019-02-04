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
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    var disposeBag: DisposeBag?
    
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
        let viewModel: EditViewModel
        let index: Int
        let data: ProfileInfoField
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        let pickerView = UIPickerView()
        
        titleLabel.text = item.data.key.title
        
        item.viewModel.input.inputTrigger[item.index]
            .bind(to: textField.rx.text)
            .disposed(by: bag)
        
        
        switch item.data.fieldType {
        case .number:
            textField.keyboardType = .numberPad
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
            
            pickerView.rx.modelSelected(Gender.self)
                .flatMapLatest({ $0.first.map({ Observable.just($0) }) ?? Observable.empty() })
                .map({ $0.title })
                .bind(to: item.viewModel.input.inputTrigger[item.index])
                .disposed(by: bag)
            
            textField.inputView = pickerView
        case .date:
            datePicker.datePickerMode = .date
            
            datePicker.rx.date
                .skip(1)
                .map { (date) -> String in
                    return date.toString()
                }
                .bind(to: item.viewModel.input.inputTrigger[item.index])
                .disposed(by: bag)
            
            textField.inputView = datePicker
            
        default:
            textField.keyboardType = .default
        }
        
        textField.rx.text
            .do(onNext: { (text) in
                switch item.data.fieldType {
                case .gender:
                    let row = Gender.index(title: text)
                    pickerView.selectRow(row, inComponent: 0, animated: false)
                default: break
                }
            })
            .bind(to: item.viewModel.input.inputTrigger[item.index])
            .disposed(by: bag)

        disposeBag = bag
    }
}
