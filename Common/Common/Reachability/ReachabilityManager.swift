//
//  ReachabilityManager.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public class ReachabilityManager {
    public static let shared = ReachabilityManager()
    private var reachability: Reachability!
    public var reachabilityStatus: NetworkStatus = NetworkStatus.init(0)
    public var isNetworkAvailable : Bool {
        return reachabilityStatus != NetworkStatus.init(0)
    }
    
    private init() {
        reachability = Reachability.forInternetConnection()
        reachabilityStatus = reachability.currentReachabilityStatus()
    }
    
    public func startMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChange(notification:)),
            name: NSNotification.Name.reachabilityChanged, object: nil)
        reachability?.startNotifier()
    }
    
    public func stopMonitoring(){
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.reachabilityChanged,
            object: nil)
    }
    
    @objc private func reachabilityChange(notification: Notification) {
        let reachability = notification.object as! Reachability
        reachabilityStatus = reachability.currentReachabilityStatus()
        switch reachabilityStatus {
        case NetworkStatus.init(0):
            print("unreachable")
            break
        default:
            print("reachable")
            break
        }
    }
}
