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
    
    @IBOutlet weak var viewProgress: UIStackView!
    @IBOutlet weak var viewProgress0: UIView!
    @IBOutlet weak var viewProgress1: UIView!
    @IBOutlet weak var viewProgress2: UIView!
    @IBOutlet weak var progress1Width: NSLayoutConstraint!
    @IBOutlet weak var progress2Width: NSLayoutConstraint!
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
        let capres1 : CGFloat = CGFloat(Int.random(in: 0...45))
        let capres2 : CGFloat = CGFloat(Int.random(in: 0...55))
        self.labelNoteParticipant.text  = "User telah berpartisipasi dalam\nGotong - Royong perhitungan Pantau Bersama"
        self.labelPresentase1.text = "\(capres1)"
        self.labelPresentase2.text = "\(capres2)"
        
        setProgress(capres1: capres1/100, capres2: capres2/100)
    }
    
    private func setProgress(capres1: CGFloat, capres2: CGFloat) {
        // check total capres 1 dan 2 tidak boleh lebih dari 100%
        if 1 < (capres1 + capres1) { return }
        let width   = self.viewProgress.frame.width
        
        // set width progress 1
        self.progress1Width.constant = width * capres1
        // set width progress 2
        self.progress2Width.constant = width * capres2
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.viewProgress.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func setMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: constraint.firstItem!, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)
    }
}
