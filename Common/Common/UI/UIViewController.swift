//
//  UIViewController.swift
//  Common
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//


import UIKit

extension UIViewController {
    public func add(childViewController: UIViewController, context: UIView) {
        addChild(childViewController)
        context.addSubview(childViewController.view)
        childViewController.view.frame = context.bounds
        childViewController.didMove(toParent: self)
    }
}
