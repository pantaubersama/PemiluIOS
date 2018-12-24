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
    case bold = "bold"
    case black = "black"
    case blackItalic = "black-italic"
    case boldItalic = "bold-italic"
    case hairline = "hairline"
    case hairlineItalic = "hairline-italic"
    case italic = "italic"
    case light = "light"
    case lightItalic = "light-italic"
    case regular = "regular"
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
    public var typeLabel: String = "regular" {
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
            initLabel()
        }
    }
}
