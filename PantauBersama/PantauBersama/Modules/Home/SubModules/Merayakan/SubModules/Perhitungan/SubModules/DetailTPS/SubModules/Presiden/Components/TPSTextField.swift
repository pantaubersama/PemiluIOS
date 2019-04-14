//
//  TPSTextField.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class TPSTextField: UITextField {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var borderColor: UIColor = Color.grey_one {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var borderColorActive: UIColor = Color.grey_one {
        didSet {
            setNeedsDisplay()
        }
    }

    let padding = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        font = UIFont(name: "Lato-Regular", size: 14)
        keyboardType = .numberPad
//        text = "\(0)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        
        layer.borderWidth = borderWidth
        if isFirstResponder {
            layer.borderColor = borderColorActive.cgColor
        } else {
            layer.borderColor = borderColor.cgColor
        }
    }
}
