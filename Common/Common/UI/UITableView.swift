//
//  UITableView.swift
//  Common
//
//  Created by Hanif Sugiyanto on 17/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

public extension UITableView {
    
    public func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: IReusableCell {
        if let nib = T.nib {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    public func registerReusableHeaderCell<T: UITableView>(_: T.Type) where T: IReusableCell {
        if let nib = T.nib {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: IReusableCell {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    public func dequeueReusableCell<T: UITableViewCell>() -> T where T: IReusableCell {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }
    
}
