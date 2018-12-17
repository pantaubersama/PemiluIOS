//
//  UIView.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//  Thanks to alfian0

import UIKit

public extension UIView {
    
    public func applyGradient(colors: [CGColor], location: [NSNumber]? = nil, position: CALayer.Position = .vertical) {
        let gradientLayer = CALayer.gradient(
            colors: colors,
            location: location,
            position: position,
            cornerRadius: self.layer.cornerRadius,
            bounds: self.bounds)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowOffset  = offset
        layer.shadowColor   = color.cgColor
        layer.shadowRadius  = radius
        layer.shadowOpacity = opacity
        layer.shadowPath    = UIBezierPath.init(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        let backgroundCGColor   = self.backgroundColor?.cgColor
        self.backgroundColor    = nil
        layer.backgroundColor   =  backgroundCGColor
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


public extension CALayer {
    
    public enum Position {
        case vertical
        case horizontal
        case diagonal
    }
    
    public static func  gradient(
        colors: [CGColor],
        location: [NSNumber]? = nil,
        position: Position = .vertical,
        cornerRadius: CGFloat = 0.0,
        bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors        = colors
        gradientLayer.locations     = location
        gradientLayer.frame         = bounds
        gradientLayer.cornerRadius  = cornerRadius
        
        switch position {
        case .diagonal:
            gradientLayer.startPoint    = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint      = CGPoint(x: 1, y: 1)
        case .vertical:
            gradientLayer.startPoint    = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint      = CGPoint(x: 0, y: 1)
        default:
            gradientLayer.startPoint    = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint      = CGPoint(x: 1, y: 0)
        }
        return gradientLayer
    }
    
}
