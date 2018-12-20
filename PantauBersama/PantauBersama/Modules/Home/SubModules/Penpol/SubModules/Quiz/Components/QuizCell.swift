//
//  QuizCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common

class QuizCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var lbTitle: Label!
    @IBOutlet weak var lbTotalQuestion: Label!
    @IBOutlet weak var btnQuiz: Button!
    @IBOutlet weak var btnShare: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
