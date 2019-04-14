//
//  RekapFooterView.swift
//  PantauBersama
//
//  Created by asharijuang on 17/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit

class RekapFooterView: UIView {
    
    @IBOutlet weak var labelNote: UILabel!
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 170)
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
        
        // set label
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)] as [NSAttributedString.Key : Any]
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.03137254902, green: 0.7411764706, blue: 0.6588235294, alpha: 1)] as [NSAttributedString.Key : Any]
        let attrs3 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)] as [NSAttributedString.Key : Any]
        
        let attributedString1 = NSMutableAttributedString(string:"Buka di ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"app.pantaubersama.com", attributes:attrs2)
        let attributedString3 = NSMutableAttributedString(string:"\nUntuk penyajian data yang lebih lengkap, hingga ke perhitungan Legislatif", attributes:attrs3)
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        self.labelNote.attributedText = attributedString1
    }
    
    
}
