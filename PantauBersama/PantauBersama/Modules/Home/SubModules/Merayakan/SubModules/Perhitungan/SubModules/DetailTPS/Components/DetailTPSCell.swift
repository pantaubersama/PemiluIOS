//
//  DetailTPSHeaderCellTableViewCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 26/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class DetailTPSCell: UITableViewCell, IReusableCell {
    struct Input {
        let viewModel: DetailTPSViewModel
    }
    
    @IBOutlet weak var btnPresiden: UIButton!
    @IBOutlet weak var btnDPRRI: UIButton!
    @IBOutlet weak var btnDPD: UIButton!
    @IBOutlet weak var btnDPRDProv: UIButton!
    @IBOutlet weak var btnDPRDKab: UIButton!
    @IBOutlet weak var btnMenu: ImageButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configureCell(item: Input) {
        
    }
    
}
