//
//  PerhitunganCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

typealias PerhitunganCellConfigured = CellConfigurator<PerhitunganCell, PerhitunganCell.Input>
class PerhitunganCell: UITableViewCell {

    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension PerhitunganCell: IReusableCell {
    
    struct Input {
        let viewModel: PerhitunganViewModel
        let data: RealCount
    }
    
    func configureCell(item: Input) {
        let feeds = item.data
        let bag = DisposeBag()
        
        configure(data: feeds)
        
//        more.rx.tap
//            .map({ feeds })
//            .bind(to: item.viewModel.input.moreTrigger)
//            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configure(data: RealCount) {
        
    }
    
}
