
//
//  BidangKajianCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class BidangKajianCell: UITableViewCell {
    
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var tagKajian: Label!
    @IBOutlet weak var btnKajian: Label!
    @IBOutlet weak var hintKajian: UIButton!
    
    var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension BidangKajianCell: IReusableCell {
    
}
