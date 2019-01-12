//
//  SettingCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

typealias SettingCellConfigured = CellConfigurator<SettingCell, SettingCell.Input>

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var label: Label!
    
    var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension SettingCell: IReusableCell {
    struct Input {
        let data: SettingData
    }
    
    func configureCell(item: Input) {
        leftIcon.image = item.data.leftIcon
        label.text = item.data.title
    }
}
