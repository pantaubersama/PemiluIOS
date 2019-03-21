//
//  SeeMoreCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class SeeMoreCell: UITableViewCell {

    @IBOutlet weak var seeMoreBtn: UIButton!
    
    private var disposeBag : DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension SeeMoreCell: IReusableCell {
    struct Input {
        let wordstadium: SectionWordstadium
        let viewModel: ILiniWordstadiumViewModel
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        seeMoreBtn.rx.tap
            .map({ item.wordstadium })
            .bind(to: item.viewModel.input.seeMoreI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
}
