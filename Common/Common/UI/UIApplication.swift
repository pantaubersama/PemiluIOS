//
//  UIApplication.swift
//  Common
//
//  Created by Hanif Sugiyanto on 27/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

extension UIApplication {
    public class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
