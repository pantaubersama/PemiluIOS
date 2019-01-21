//
//  FilterRadioCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import LTHRadioButton

class FilterRadioCell: UITableViewCell, IReusableCell {
    @IBOutlet weak var radioView: UIView!
    @IBOutlet weak var lbTitle: Label!
    
    var item: PenpolFilterModel.FilterItem!
    
    lazy var radioButton: LTHRadioButton = {
        let rb = LTHRadioButton(selectedColor: Color.primary_red)
        rb.contentMode = .center
        rb.translatesAutoresizingMaskIntoConstraints = false
        
        return rb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        radioView.addSubview(radioButton)
        
        NSLayoutConstraint.activate([
            radioButton.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),
            radioButton.centerXAnchor.constraint(equalTo: radioView.centerXAnchor),
            radioButton.heightAnchor.constraint(equalToConstant: radioButton.frame.height),
            radioButton.widthAnchor.constraint(equalToConstant: radioButton.frame.width)]
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(item: PenpolFilterModel.FilterItem) {
        self.item = item
        lbTitle.text = item.title
        
        if item.isSelected {
            radioButton.select()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            radioButton.select()
        } else {
            radioButton.deselect()
        }
        // Configure the view for the selected state
    }
    
}
