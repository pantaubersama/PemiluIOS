//
//  WordstadiumItemViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common

class WordstadiumItemViewCell: UITableViewCell {

    @IBOutlet weak var backgroundItem: UIImageView!
    @IBOutlet weak var footerContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension WordstadiumItemViewCell: IReusableCell {
    
    struct Input {
        let type : ItemType
    }
    
    func configureCell(item: Input) {
        var footerView: UIView!
        
        switch item.type {
        case .comingsoon:
            backgroundItem.image = UIImage(named: "bgWordstadiumComingsoon")
            footerView = TimeView()
        case .done:
            backgroundItem.image = UIImage(named: "bgWordstadiumDone")
            footerView = ClapView()
        case .challenge:
            backgroundItem.image = UIImage(named: "bgWordstadiumChallange")
            footerView = DescriptionView()
        default: break
            
        }
        
        footerContainerView.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // MARK: constraint footerView
            footerView.leadingAnchor.constraint(equalTo: footerContainerView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: footerContainerView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: footerContainerView.topAnchor),
            footerView.bottomAnchor.constraint(equalTo: footerContainerView.bottomAnchor)
            ])
        
    }
}
