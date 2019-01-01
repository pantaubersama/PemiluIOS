//
//  ClusterCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking
import AlamofireImage

typealias ClusterCellConfigured = CellConfigurator<ClusterCell, ClusterCell.Input>

class ClusterCell: UITableViewCell {
    
    
    @IBOutlet weak var iconCluster: UIImageView!
    @IBOutlet weak var titleCluster: Label!
    
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension ClusterCell: IReusableCell {
    
    struct Input {
        let data: User?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        titleCluster.text = item.data?.cluster?.name
        if let thumbnail = item.data?.cluster?.image.thumbnail.url {
            iconCluster.af_setImage(withURL: URL(string: thumbnail)!)
        }
        
        disposeBag = bag
    }
}
