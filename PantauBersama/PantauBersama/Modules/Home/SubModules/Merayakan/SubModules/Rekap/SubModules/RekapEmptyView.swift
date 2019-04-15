//
//  RekapEmptyView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit

class RekapEmptyView: UIView {
    
    @IBOutlet weak var lblInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        configure()
    }
    
    func configure() {
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)] as [NSAttributedString.Key : Any]
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.03137254902, green: 0.7411764706, blue: 0.6588235294, alpha: 1)] as [NSAttributedString.Key : Any]
        let attrs3 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)] as [NSAttributedString.Key : Any]
        
        
        let attributedString1 = NSMutableAttributedString(string:"Rekapitulasi pemilu serentak seluruh Indonesia akan aktif ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"17 April 2019", attributes:attrs2)
        let attributedString3 = NSMutableAttributedString(string:" nanti", attributes:attrs3)
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        self.lblInfo.attributedText = attributedString1
    }
    
}
