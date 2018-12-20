//
//  ImageButton.swift
//  Common
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ImageButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        let normalImage = imageIcon?.withRenderingMode(.alwaysTemplate)
        self.setImage(normalImage, for: .normal)
        self.imageView?.tintColor = imageTintColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.imageView?.tintColor = imagePressedTintColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.imageView?.tintColor = imageTintColor
    }
    
    @IBInspectable
    public var imageIcon: UIImage? = nil {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var imageTintColor: UIColor? = nil {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var imagePressedTintColor: UIColor? = nil {
        didSet {
            setupView()
        }
    }
}
