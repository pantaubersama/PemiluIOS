//
//  DebatCommentCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class DebatCommentCell: UITableViewCell, IReusableCell {

    @IBOutlet weak var lbCreatedAt: Label!
    @IBOutlet weak var lbContent: Label!
    @IBOutlet weak var lbName: Label!
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var viewRedDot: RoundView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
