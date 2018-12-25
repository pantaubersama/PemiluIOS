//
//  DateViewCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

typealias DateViewCellConfigured = CellConfigurator<DateViewCell, DateViewCell.Input>

class DateViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var textField: TextField!
    
    var disposeBag: DisposeBag!
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.inputView = datePicker
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
}

extension DateViewCell: IReusableCell {
    struct Input {
        let viewModel: ProfileEditViewModel
        let index: Int
        let data: ProfileInfoField
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
    }
}
