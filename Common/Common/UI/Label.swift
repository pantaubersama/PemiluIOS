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
    case bmBold = "bm-bold"
    case bmExtraBold = "bm-extra-bold"
    case bmLight = "bm-light"
    case bmBlack = "bm-black"
    case bmThin = "bm-thin"
    
    var fontName: String {
        switch self {
        case .bold:
            return "Lato-Bold"
        case .black:
            return "Lato-Black"
        case .blackItalic:
            return "Lato-BlackItalic"
        case .boldItalic:
            return "Lato-BoldItalic"
        case .hairline:
            return "Lato-Hairline"
        case .hairlineItalic:
            return "Lato-HairlineItalic"
        case .italic:
            return "Lato-Italic"
        case .light:
            return "Lato-Light"
        case .lightItalic:
            return "Lato-LightItalic"
        case .regular:
            return "Lato-Regular"
        case .bmBold:
            return "BwModelicaSS01-BoldCondensed"
        case .bmThin:
            return "BwModelica-ThinCondensed"
        case .bmBlack:
            return "BwModelica-BlackCondensed"
        case .bmLight:
            return "BwModelica-LightCondensed"
        case .bmExtraBold:
            return "BwModelica-ExtraBoldCondensed"
        }
    }
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
            if let type = LabelType(rawValue: self.typeLabel.lowercased()) {
                self.fontName = type.fontName
            }
            initLabel()
        }
    }
}

// MARK: Extension Label Readmore
extension UILabel {
    
    public func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}
