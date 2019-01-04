//
//  Button.swift
//  Common
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
open class Button: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override open func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        refreshLayout()
    }
    
    func refreshLayout() {
        initButton()
    }
    
    func initButton(){
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1
        self.titleLabel?.font = UIFont(name: self.fontName, size: self.fontSize)
    }
    
    var fontName: String = "Lato-Regular"
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            initButton()
        }
    }
    
    @IBInspectable
    public var fontSize: CGFloat = 12 {
        didSet {
            initButton()
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = UIColor.clear {
        didSet {
            initButton()
        }
    }
    
    @IBInspectable
    public var typeButton: String = "regular" {
        didSet {
            if let newFont: LabelType = LabelType(rawValue: self.typeButton.lowercased()) {
                switch newFont {
                case .bold:
                    self.fontName = "Lato-Bold"
                case .boldItalic:
                    self.fontName = "Lato-BoldItalic"
                case .italic:
                    self.fontName = "Lato-Italic"
                case .light:
                    self.fontName = "Lato-Light"
                case .regular:
                    self.fontName = "Lato-Regular"
                case .black:
                    self.fontName = "Lato-Black"
                case .blackItalic:
                    self.fontName = "Lato-BlackItalic"
                case .hairline:
                    self.fontName = "Lato-Hairline"
                case .hairlineItalic:
                    self.fontName = "Lato-HairlineItalic"
                case .lightItalic:
                    self.fontName = "Lato-LightItalic"
                }
            }
        }
    }
}
