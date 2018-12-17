//
//  IReusableCell.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
// Thanks to alfian0

import UIKit

public protocol IReusableCell {
    associatedtype DataType
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
    static var height: CGFloat { get }
    func configureCell(item: DataType)
}

public extension IReusableCell {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    public static var nib: UINib? {
        guard let _ = Bundle.main.path(forResource: reuseIdentifier, ofType: "nib") else { return nil }
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    public static var height: CGFloat {
        return 0.0
    }
    
    func configureCell(item: Any) {
        
    }
}
