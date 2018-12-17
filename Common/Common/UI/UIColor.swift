//
//  UIColor.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public class Color: UIColor {
    
    public static func RGBColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    public static func RGBColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return RGBColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
}

extension Color {
    // Primary color Pantau Bersama Themes
    public static var primary_red: UIColor {
        return Color.RGBColor(red: 189, green: 8, blue: 28)
    }
    // Shades color Pantau Bersama included red-brown
    public static var red_pink: UIColor {
        return Color.RGBColor(red: 255, green: 235, blue: 239)
    }
    
    public static var red_pink_warm: UIColor {
        return Color.RGBColor(red: 233, green: 113, blue: 117)
    }
  
    public static var red_light: UIColor {
        return Color.RGBColor(red: 235, green: 48, blue: 55)
    }
    
    public static var red_brown_one: UIColor {
        return Color.RGBColor(red: 155, green: 0, blue: 18)
    }
    
    public static var red_brown_two: UIColor {
        return Color.RGBColor(red: 133, green: 0, blue: 0)
    }
    
    public static var red_brown: UIColor {
        return Color.RGBColor(red: 103, green: 1, blue: 13)
    }
    // Black and White styles in Pantau
    public static var primary_white: UIColor {
        return Color.RGBColor(red: 249, green: 249, blue: 249)
    }
    
    public static var grey_one: UIColor {
        return Color.RGBColor(red: 244, green: 244, blue: 244)
    }
    
    public static var grey_two: UIColor {
        return Color.RGBColor(red: 236, green: 236, blue: 236)
    }
    
    public static var grey_three: UIColor {
        return Color.RGBColor(red: 203, green: 203, blue: 203)
    }
    
    public static var grey_four: UIColor {
        return Color.RGBColor(red: 124, green: 124, blue: 124)
    }
    
    public static var grey_five: UIColor {
        return Color.RGBColor(red: 79, green: 79, blue: 79)
    }
    
    public static var grey_six: UIColor {
        return Color.RGBColor(red: 57, green: 57, blue: 57)
    }
    // Black light for Pantau
    public static var black_light: UIColor {
        return Color.RGBColor(red: 33, green: 33, blue: 33)
    }
    // Black primary in Pantau
    public static var primary_black: UIColor {
        return Color.RGBColor(red: 17, green: 17, blue: 17)
    }
    
    // Secondary Themes in Pantau: Orange
    public static var secondary_orange: UIColor {
        return Color.RGBColor(red: 246, green: 180, blue: 42)
    }
    // Secondary Orange themes include shades
    public static var orange_shades_one: UIColor {
        return Color.RGBColor(red: 254, green: 248, blue: 227)
    }
    
    public static var orange_shades_two: UIColor {
        return Color.RGBColor(red: 249, green: 214, blue: 92)
    }
    
    // Themes warm orange Pantau
    public static var orange_warm: UIColor {
        return Color.RGBColor(red: 244, green: 148, blue: 34)
    }
    
    public static var orange_warm_dark: UIColor {
        return Color.RGBColor(red: 242, green: 119, blue: 29)
    }
    
    // Themes Cyan Pantau
    public static var secondary_cyan: UIColor {
        return Color.RGBColor(red: 8, green: 189, blue: 168)
    }
    // Secondary Cyan thems include shades
    public static var cyan_shades_one: UIColor {
        return Color.RGBColor(red: 221, green: 244, blue: 241)
    }
    public static var cyan_shades_two: UIColor {
        return Color.RGBColor(red: 109, green: 208, blue: 193)
    }
    public static var cyan_warm_light: UIColor {
        return Color.RGBColor(red: 0, green: 145, blue: 117)
    }
    public static var cyan_warm_dark: UIColor {
        return Color.RGBColor(red: 0, green: 112, blue: 87)
    }
    
}
