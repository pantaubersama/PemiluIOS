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
        let data: SettingProfile
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        titleLabel.text = item.data.key
        
        
    }
}
