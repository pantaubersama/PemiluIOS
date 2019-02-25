//
//  TextField.swift
//  Common
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit


enum TextFieldType: String {
    case bw = "BwModelicaSS01-BoldCondensed"
    case lato = "Lato-Bold"
}

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
    public var icon: UIImage? = nil {
        didSet {
            setupTextField()
        }
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
    
    func initFont() {
        self.font = UIFont(name: self.fontName, size: self.fontSize)
    }
    
    @IBInspectable
    public var fontSize: CGFloat = 12 {
        didSet {
            initFont()
        }
    }

    var fontName: String = "BwModelicaSS01-BoldCondensed"
    
    
    @IBInspectable
    public var typeTextField: String = "lato" {
        didSet {
            if let newFont: TextFieldType = TextFieldType(rawValue: self.typeTextField.lowercased()) {
                switch newFont {
                case .bw:
                    self.fontName = "BwModelicaSS01-BoldCondensed"
                case .lato:
                    self.fontName = "Lato-Bold"
                }
            }
            initFont()
        }
    }
    
    func setupTextField() {
        self.borderStyle = .none
        self.setBottomBorder(color: lineColor)
        
        if let `placeholder` = placeholder {
            self.font = UIFont(name: "BwModelicaSS01-BoldCondensed", size: 12)
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: Color.grey_two,
                NSAttributedString.Key.font: UIFont(name: "BwModelicaSS01-BoldCondensed", size: 12) ?? UIFont.systemFont(ofSize: 14)
            ]
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
        

        if let imageIcon = icon {
            let imageIcon = UIImageView(image: imageIcon)
            imageIcon.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(imageIcon)
            
            NSLayoutConstraint.activate([
                imageIcon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
                imageIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                imageIcon.heightAnchor.constraint(equalToConstant: 24),
                imageIcon.widthAnchor.constraint(equalToConstant: 24)
                ])
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
