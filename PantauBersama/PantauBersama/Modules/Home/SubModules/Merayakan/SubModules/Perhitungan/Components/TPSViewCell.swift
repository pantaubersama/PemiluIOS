//
//  TPSViewCell.swift
//  PantauBersama
//
//  Created by asharijuang on 20/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class TPSViewCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var regionView: UIView!
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension TPSViewCell : IReusableCell {
    func configure(data: String) {
        
    }
}
