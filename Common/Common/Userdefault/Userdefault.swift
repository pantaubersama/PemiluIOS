//
//  Userdefault.swift
//  Common
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

/*
 * How to use
 * - get: you need casting type first
 *        let firstTimeInstall: Bool? = UserDefaults.Account.get(forKey: .firstTimeInstall)
 * - set: UserDefaults.Account.set(false, forKey: .firstTimeInstall)
 * - reset: UserDefaults.Account.reset()
 *          UserDefaults.Account.reset(forKey: .firstTimeInstall)
 */

public protocol KeyNamespaceable {
    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String
}

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return "\(Self.self).\(key)"
    }
    
    public static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }
}

public protocol AccountDefaultable: KeyNamespaceable {
    associatedtype AccountDefaultKey: RawRepresentable
}

public extension AccountDefaultable where AccountDefaultKey.RawValue == String {
    
    public static func set(_ value: Any, forKey key: AccountDefaultKey) {
        UserDefaults.standard.set(value, forKey: namespace(key))
    }
    
    public static func get<T>(forKey key: AccountDefaultKey) -> T? {
        guard let value = UserDefaults.standard.object(forKey: namespace(key)) as? T else {
            return nil
        }
        
        return value
    }
    
    public static func reset(forKey key: AccountDefaultKey) {
        UserDefaults.standard.removeObject(forKey: namespace(key))
    }
    
    public static func reset() {
        for (key, _) in list() {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    static private func list() -> [String: Any] {
        let allDefaults = UserDefaults.standard.dictionaryRepresentation()
        var myDefaults = [String: Any]()
        
        for (key, value) in allDefaults {
            if key.hasPrefix("\(Self.self)") {
                myDefaults[key] = value
            }
        }
        
        return myDefaults
    }
}

public extension UserDefaults {
    
    public struct Account: AccountDefaultable {
        private init() { }
        
        public enum AccountDefaultKey: String {
            case firstTimeInstall
            case userData
        }
    }
}
