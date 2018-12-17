//
//  Label.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import UIKit


enum LabelType: String {
    case bold = "Bold"
    case black = "Black"
    case blackItalic = "BlackItalic"
    case boldItalic = "BoldItalic"
    case hairline = "Hairline"
    case hairlineItalic = "HairlineItalic"
    case italic = "Italic"
    case light = "Light"
    case lightItalic = "LightItalic"
    case regular = "Regular"
}


@IBDesignable
public class Label: UILabel {
    
    var fontName: String = "Lato-Regular"
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        refreshLayout()
    }
    
    func refreshLayout() {
        initLabel()
    }
    
    func initLabel() {
        self.font = UIFont(name: self.fontName, size: self.fontSize)
    }
    
    @IBInspectable
    public var fontSize: CGFloat = 12 {
        didSet {
            initLabel()
        }
    }
    
    @IBInspectable
    public var typeLabel: String = "Regular" {
        didSet {
            if let newFont: LabelType = LabelType(rawValue: self.typeLabel.lowercased()) {
                switch newFont {
                case .bold:
                    self.fontName = "Lato-Bold"
                case .black:
                    self.fontName = "Lato-Black"
                case .blackItalic:
                    self.fontName = "Lato-BlackItalic"
                case .boldItalic:
                    self.fontName = "Lato-BoldItalic"
                case .hairline:
                    self.fontName = "Lato-Hairline"
                case .hairlineItalic:
                    self.fontName = "Lato-HairlineItalic"
                case .italic:
                    self.fontName = "Lato-Italic"
                case .light:
                    self.fontName = "Lato-Light"
                case .lightItalic:
                    self.fontName = "Lato-LightItalic"
                case .regular:
                    self.fontName = "Lato-Regular"
                }
            }
        }
    }
}
