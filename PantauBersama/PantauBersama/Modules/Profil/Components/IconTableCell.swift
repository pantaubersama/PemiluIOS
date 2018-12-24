//
//  IconTableCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

typealias BiodataCellConfigured = CellConfigurator<IconTableCell, IconTableCell.Input>

class IconTableCell: UITableViewCell {

    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

extension IconTableCell: IReusableCell {
    struct Input {
        
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        disposeBag = bag
    }
}
