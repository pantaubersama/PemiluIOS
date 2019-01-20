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
