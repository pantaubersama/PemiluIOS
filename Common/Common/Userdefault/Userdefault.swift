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
            case tokenType
            case me
            case informant
            case userIdTwitter
            case usernameTwitter
            case usernameFacebook
            case clusterName
            case clusterCategory
            case version
            case skipVersion
            case instanceId
            /// For merayakan
            case provinceCode
            case regencyCode
            case districtCode
            case villagesCode
            case nameProvince
            case nameRegency
            case nameDistrict
            case nameVillages
            case noTPS
        }
    }
}

public extension UserDefaults {
    public static func setSelectedFilter(value: String, isSelected: Bool) {
        let userDefault = UserDefaults.standard
        if isSelected {
            userDefault.set(true, forKey: value)
        } else {
            userDefault.removeObject(forKey: value)
        }
    }
    
    public static func setClusterFilter(userInfo: [String: String]) {
        UserDefaults.standard.set(userInfo, forKey: "cluster_filter")
    }
    
    public static func getClusterFilter() -> [String: String]? {
        return UserDefaults.standard.dictionary(forKey: "cluster_filter") as? [String : String]
    }
    
    public static func resetClusterFilter() {
        UserDefaults.standard.removeObject(forKey: "cluster_filter")
    }
    
    public static func setCategoryFilter(userInfo: [String: String]) {
        UserDefaults.standard.set(userInfo, forKey: "category_filter")
    }
    
    public static func getCategoryFilter() -> [String: String]? {
        return UserDefaults.standard.dictionary(forKey: "category_filter") as? [String : String]
    }
    
    public static func resetCategoryFilter() {
        UserDefaults.standard.removeObject(forKey: "category_filter")
    }
    
    
    
    public static func isSelectedFilter(value: String) -> Bool {
        return UserDefaults.standard.bool(forKey: value)
    }
    
    public static func addRecentlySearched(query: String) {
        if query.isEmpty {
            return
        }
        
        let lowerCasedQuery = query.lowercased()
        var newRecentlySearched: [String] = []
        
        // get existing recently search if exist
        if let cachedRecentlySearched = getRecentlySearched() {
            newRecentlySearched = cachedRecentlySearched
        }
        
        // if query already contaned inside existing list, then just reorder to the first order
        if newRecentlySearched.contains(lowerCasedQuery) {
            let containedIndex = newRecentlySearched.firstIndex { (cachedQuery) -> Bool in
                return cachedQuery.lowercased() == lowerCasedQuery
            }
            
            newRecentlySearched.remove(at: containedIndex!)
        }
        
        // if existing list already reached limit (5) than remove the oldest one
        if newRecentlySearched.count == 5 {
            newRecentlySearched.removeLast()
        }
        
        newRecentlySearched.insert(lowerCasedQuery, at: 0)
        
        UserDefaults.standard.set(newRecentlySearched, forKey: "recently_searched")
    }
    
    public static func getRecentlySearched() -> [String]? {
        return UserDefaults.standard.array(forKey: "recently_searched") as? [String]
    }
    
    public static func clearRecentlySearched() {
        UserDefaults.standard.removeObject(forKey: "recently_searched")
    }
}
