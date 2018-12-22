//
//  ICellConfigurator.swift
//  Common
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation

public protocol ICellConfigurator {
    var reuseIdentifier: String { get }
    func configure(cell: UIView)
}

public struct CellConfigurator<CellType: IReusableCell, DataType>: ICellConfigurator where CellType.DataType == DataType {
    
    public let item: DataType
    public var reuseIdentifier: String {
        return CellType.reuseIdentifier
    }
    
    public init(item: DataType) {
        self.item = item
    }
    
    public func configure(cell: UIView) {
        (cell as? CellType)?.configureCell(item: item)
    }
}

public typealias BaseCellConfigured = CellConfigurator<BaseCell, Void>

public class BaseCell: UITableViewCell, IReusableCell {
    public func configureCell(item: Void) {
        
    }
}
