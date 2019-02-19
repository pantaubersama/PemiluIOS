//
//  RoundView.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
public class RoundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayout()
    }
    
    func initLayout(){
        
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            initLayout()
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    public var leftRadius: CGFloat = 0.0 {
        didSet {
            initLayout()
            self.roundCorners([.topLeft, .bottomLeft], radius: leftRadius)
        }
    }
    
    @IBInspectable
    public var rightRadius: CGFloat = 0.0 {
        didSet {
            initLayout()
            self.roundCorners([.topRight, .bottomRight], radius: rightRadius)
        }
    }
    
    @IBInspectable
    public var topRadius: CGFloat = 0.0 {
        didSet {
            initLayout()
            self.roundCorners([.topRight, .topLeft], radius: topRadius)
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = UIColor.clear {
        didSet {
            initLayout()
        }
    }
    
}
