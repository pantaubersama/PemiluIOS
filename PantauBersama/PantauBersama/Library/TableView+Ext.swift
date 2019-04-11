//
//  TableView+Ext.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 11/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Set table header view & add Auto layout.
    public func setTableHeaderView(headerView: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set first.
        self.tableHeaderView = headerView
        
        // Then setup AutoLayout.
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        updateHeaderViewFrame()
    }
    
    /// Update header view's frame.
    public func updateHeaderViewFrame() {
        guard let headerView = self.tableHeaderView else { return }
        
        // Update the size of the header based on its internal content.
        headerView.layoutIfNeeded()
        
        // ***Trigger table view to know that header should be updated.
        let header = self.tableHeaderView
        self.tableHeaderView = header
    }
    
    public func setTableFooterView(footerView: UIView) {
        self.tableFooterView = footerView
    }
}
