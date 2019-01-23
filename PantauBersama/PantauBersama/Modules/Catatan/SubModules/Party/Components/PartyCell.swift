//
//  PartyCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 23/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

typealias PartyCellConfigured = CellConfigurator<PartyCell, PartyCell.Input>

class PartyCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var ivParty: UIImageView!
    @IBOutlet weak var lblParty: UILabel!
    @IBOutlet weak var lblUrutan: Label!
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            container.backgroundColor = Color.orange_warm
            lblParty.textColor = Color.primary_white
            lblUrutan.textColor = Color.primary_white
        } else {
            container.backgroundColor = Color.primary_white
            lblParty.textColor = Color.primary_black
            lblUrutan.textColor = Color.primary_black
        }
    }
}

extension PartyCell: IReusableCell {
    
    struct Input {
        let data: PoliticalParty
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lblParty.text = item.data.name
        lblUrutan.text = "No urut \(item.data.number)"
        if let thumbnail = item.data.image.thumbnail.url {
            ivParty.af_setImage(withURL: URL(string: thumbnail)!)
        }
        
        disposeBag = bag
    }
    
    
}
