//
//  UINavigationBar.swift
//  Common
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

extension UINavigationBar {
    
    public enum NavigationBarKind {
        case solid(color: UIColor)
        case white
        case transparent
    }
    public enum BarType {
        case `default`
        case kuis
        case pantau
        case wordstadium
        
        var color: UIColor {
            switch self {
            case .default:
                return Color.primary_white
            case .kuis:
                return Color.primary_red
            case .pantau:
                return Color.primary_red
            case .wordstadium:
                return Color.secondary_orange
            }
        }
    }
    
    public func configure(type: BarType) {
        configure(with: .solid(color: type.color))
    }
    
    public func configure(with type: NavigationBarKind) {
        switch type {
        case .solid(let color):
            shadowImage = UIImage()
            isTranslucent = false
            tintColor = Color.primary_white
            barTintColor = color
            titleTextAttributes = [
                NSAttributedString.Key(
                    rawValue: NSAttributedString.Key.foregroundColor.rawValue
                ): UIColor.white
            ]
            backgroundColor     = color
        case .white:
            shadowImage = UIImage()
            isTranslucent = false
            tintColor = Color.primary_black
            barTintColor        = Color.primary_white
            backgroundColor     = UIColor.clear
            titleTextAttributes = [
                NSAttributedString.Key(
                    rawValue: NSAttributedString.Key.foregroundColor.rawValue
                ): Color.primary_black
            ]
        case .transparent:
            setBackgroundImage(UIImage(), for: .default)
            shadowImage         = UIImage()
            isTranslucent       = true
            tintColor           = UIColor.white
            titleTextAttributes = [
                NSAttributedString.Key(
                    rawValue: NSAttributedString.Key.foregroundColor.rawValue
                ): UIColor.white
            ]
            barTintColor        = UIColor.clear
            backgroundColor     = UIColor.clear
        }
    }
}
