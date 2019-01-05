//
//  CircularUIImage.swift
//  Common
//
//  Created by Rahardyan Bisma Setya Putra on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit

public class CircularUIImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func prepareForInterfaceBuilder() {
        setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}
