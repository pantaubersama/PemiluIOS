//
//  Localized.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

// Taken from
// 1. https://github.com/marmelroy/Localize-Swift
// 2. https://www.youtube.com/watch?v=Nk9u19IQQIk

import Foundation

public class Localized: NSObject {
    
    static let kLanguage = "Lang"
    static let kBaseLanguage = "Base"
    static let kDefaultLanguage = "en"
    
    open class func availableLanguages() -> [String] {
        var availableLanguages = Bundle.main.localizations
        if let indexOfBase = availableLanguages.index(of: kBaseLanguage) {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    
    open class func defaultLanguage() -> String {
        var defaultLanguage: String = String()
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return kDefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if (availableLanguages.contains(preferredLanguage)) {
            defaultLanguage = preferredLanguage
        } else {
            defaultLanguage = kDefaultLanguage
        }
        return defaultLanguage
    }
    
    open class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: kLanguage) as? String {
            return currentLanguage
        }
        return defaultLanguage()
    }
    
    open class func setCurrentLanguage(_ language: String) {
        let selectedLanguage = availableLanguages().contains(language) ? language : defaultLanguage()
        if (selectedLanguage != currentLanguage()){
            UserDefaults.standard.set(selectedLanguage, forKey: kLanguage)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kLanguage), object: nil)
        }
    }
    
    open class func resetCurrentLanguageToDefault() {
        setCurrentLanguage(defaultLanguage())
    }
    
}
