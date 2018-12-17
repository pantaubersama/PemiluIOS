//
//  String+Localizable.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

// Taken from
// 1. https://github.com/marmelroy/Localize-Swift
// 2. https://www.youtube.com/watch?v=Nk9u19IQQIk

import Foundation

public extension String {
    
    public func localized() -> String {
        return localized(bundle: nil)
    }
    
    private func localized(bundle: Bundle? = nil) -> String {
        let bundle: Bundle = bundle ?? .main
        if let path = bundle.path(forResource: Localized.currentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
        return self
    }
    
}
