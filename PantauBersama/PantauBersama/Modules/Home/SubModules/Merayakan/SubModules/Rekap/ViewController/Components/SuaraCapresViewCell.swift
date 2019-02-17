//
//  SuaraCapresViewCell.swift
//  PantauBersama
//
//  Created by asharijuang on 17/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class SuaraCapresViewCell: UITableViewCell {

    @IBOutlet weak var labelParticipant: UILabel!
    @IBOutlet weak var labelNoteParticipant: UILabel!
    @IBOutlet weak var labelUpdated: UILabel!
    @IBOutlet weak var labelPresentase1: UILabel!
    @IBOutlet weak var labelPresentase2: UILabel!
    @IBOutlet weak var labelSuara1: UILabel!
    @IBOutlet weak var labelSuara2: UILabel!
    
    @IBOutlet weak var imageViewCapres1: UIImageView!
    @IBOutlet weak var imageViewCapres2: UIImageView!
    
    @IBOutlet weak var ratioProgressCapres1: NSLayoutConstraint!
    @IBOutlet weak var ratioProgressCapres2: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SuaraCapresViewCell : IReusableCell {
    
    
    func configureCell(item: Any) {
        self.labelNoteParticipant.text  = "User telah berpartisipasi dalam\nGotong - Royong perhitungan Pantau Bersama"
        
        
    }
    
    private func setProgress(capres1: Double, capres2: Double) {
        // check total capres 1 dan 2 tidak boleh lebih dari 100%
        
        self.ratioProgressCapres1 = setMultiplier(constraint: self.ratioProgressCapres1, multiplier: 0.47)
    }
    
    private func setMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: constraint.firstItem!, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)
    }
}
