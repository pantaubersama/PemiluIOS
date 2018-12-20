//
//  AppContext.swift
//  Common
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public class AppContext {
    
    init() {
        
    }
    
    public static var instance: AppContext {
        return AppContext()
    }
    
    public func infoForKey(_ key: String) -> String {
        return ((Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: ""))!
    }
}
