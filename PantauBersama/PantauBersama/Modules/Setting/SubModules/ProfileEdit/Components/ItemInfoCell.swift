//
//  ItemInfoCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import Common
import RxSwift
import RxCocoa
import Networking

typealias ItemInfoCellConfigured = CellConfigurator<ItemInfoCell, ItemInfoCell.Input>

class ItemInfoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var titleValue: Label!
    
    
    var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
}

extension ItemInfoCell: IReusableCell {
    struct Input {
        let data: ProfileInfoField
    }
    
    func configureCell(item: Input) {
        titleLabel.text = item.data.key.title
        titleValue.text = item.data.value
    }
}
