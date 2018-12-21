//
//  UITextField.swift
//  Common
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public extension UITextField {
    public func setBottomBorder(color: UIColor) {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor   = color.cgColor
        self.layer.shadowOffset  = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius  = 0.0
    }
    
    public func reset() {
        text = ""
        sendActions(for: .valueChanged)
    }
}
