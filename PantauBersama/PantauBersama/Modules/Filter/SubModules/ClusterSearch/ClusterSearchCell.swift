//
//  ClusterSearchCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking
import AlamofireImage

typealias ClusterSearchCellConfigured = CellConfigurator<ClusterSearchCell, ClusterSearchCell.Input>

class ClusterSearchCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameCluster: Label!
    @IBOutlet weak var countMember: Label!
    
    private var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
}


extension ClusterSearchCell: IReusableCell {
    
    struct Input {
        let data: ClusterDetail
    }
    
    func configureCell(item: Input) {
        print(item.data)
        if let thumbnail = item.data.image.thumbnail.url {
            icon.af_setImage(withURL: URL(string: thumbnail)!)
        }
        nameCluster.text = item.data.name
        countMember.text = "\(item.data.memberCount) Anggota"
    }
    
}
