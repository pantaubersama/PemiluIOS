//
//  LinimasaCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift

class LinimasaCell: UITableViewCell, IReusableCell  {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: Label!
    @IBOutlet weak var content: Label!
    @IBOutlet weak var titleTeam: Label!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var more: UIButton!
    
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}
