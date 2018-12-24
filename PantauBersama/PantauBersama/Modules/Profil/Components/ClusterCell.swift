//
//  ClusterCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

typealias ClusterCellConfigured = CellConfigurator<ClusterCell, ClusterCell.Input>

class ClusterCell: UITableViewCell {
    
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension ClusterCell: IReusableCell {
    struct Input {
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        
        disposeBag = bag
    }
}
