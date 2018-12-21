//
//  TextField.swift
//  Common
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
public class TextField: UITextField {
    
    let border = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        setupTextField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        setupTextField()
    }
    
    override public func prepareForInterfaceBuilder() {
        setupTextField()
    }
    
    @IBInspectable
    public var lineColor: UIColor = Color.grey_two {
        didSet {
            setupTextField()
        }
    }
    
    @IBInspectable
    public var activeLineColor: UIColor = Color.red_pink {
        didSet {
            setupTextField()
        }
    }
    
    func setupTextField() {
        self.borderStyle = .none
        self.setBottomBorder(color: lineColor)
        
        if let `placeholder` = placeholder {
            self.font = UIFont(name: "BwModelicaSS01-BoldCondensed", size: 14)
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: Color.grey_two,
                NSAttributedString.Key.font: UIFont(name: "BwModelicaSS01-BoldCondensed", size: 14) ?? UIFont.systemFont(ofSize: 14)
            ]
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
    
    public func editingMode(active: Bool) {
        let color = active ? activeLineColor : lineColor
        self.setBottomBorder(color: color)
    }
    
}

extension TextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        editingMode(active: true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        editingMode(active: false)
    }
}
