//
//  OrderFormatter.swift
//  Common
//
//  Created by Rahardyan Bisma Setya Putra on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

extension Int {
    // TODO: find any better solution, limited to 30,
    public var stringOrder: String {
        if self == 1 {
            return "pertama"
        }
        
        return "ke"+self.stringFormat
    }
    
    public var stringFormat: String {
        if self <= 10 {
            return mainNumber
        } else if self > 10 && self <= 20 {
            if self == 11 {
                return "sebelas"
            } else if self == 20 {
                return "duapuluh"
            } else {
                return mainNumber + "belas"
            }
        } else if self > 20 && self <= 30 {
            if self == 30 {
                return "tigapuluh"
            }
            
            return "duapuluh " + (self % 20).mainNumber
        } else {
            return ""
        }
        
    }
    
    private var mainNumber: String {
        switch self {
        case 1:
            return "satu"
        case 2:
            return "dua"
        case 3:
            return "tiga"
        case 4:
            return "empat"
        case 5:
            return "lima"
        case 6:
            return "enam"
        case 7:
            return "tujuh"
        case 8:
            return "delapan"
        case 9:
            return "sembilan"
        case 10:
            return "sepuluh"
        default:
            return ""
        }
    }
}
