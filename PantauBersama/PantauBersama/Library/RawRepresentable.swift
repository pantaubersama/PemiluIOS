//
//  RawRepresentable.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18 from Alfian0
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

extension RawRepresentable where RawValue == Int {
    
    static var itemCount: Int {
        var index = 0
        while Self(rawValue: index) != nil {
            index += 1
        }
        
        return index
    }
    
    static var items: [Self] {
        var items = [Self]()
        var index = 0
        while let item = Self(rawValue: index) {
            items.append(item)
            index += 1
        }
        
        return items
    }
}
