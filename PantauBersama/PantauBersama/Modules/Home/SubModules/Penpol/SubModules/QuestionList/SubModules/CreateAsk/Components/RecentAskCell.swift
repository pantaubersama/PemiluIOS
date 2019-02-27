//
//  RecentAskCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 27/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class RecentAskCell: UITableViewCell {
    
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnAsk: UIButton!
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
}

extension RecentAskCell: IReusableCell {
    
    
    
}
