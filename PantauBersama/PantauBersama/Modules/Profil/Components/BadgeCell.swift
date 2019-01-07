//
//  BadgeCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import Networking
import AlamofireImage

typealias BadgeCellConfigured = CellConfigurator<BadgeCell, BadgeCell.Input>

class BadgeCell: UITableViewCell {
    
    @IBOutlet weak var iconBadges: UIImageView!
    @IBOutlet weak var nameBadges: Label!
    @IBOutlet weak var descriptionBadges: Label!
    @IBOutlet weak var shareButton: UIButton!
    
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension BadgeCell: IReusableCell {
    struct Input {
        let badges: Badges
        let isAchieved: Bool
        let viewModel: BadgeViewModel
        let idAchieved: String?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        if let thumbnail = item.badges.image.thumbnail.url {
            item.isAchieved ?
                iconBadges.af_setImage(withURL: URL(string: thumbnail)!) :
                // use gray images from url
                iconBadges.af_setImage(withURL: URL(string: thumbnail)!)
        }
        nameBadges.text = item.badges.name
        descriptionBadges.text = item.badges.description
        nameBadges.textColor = item.isAchieved ? Color.primary_black : Color.grey_three
        descriptionBadges.textColor = item.isAchieved ? Color.primary_black : Color.grey_three
        shareButton.isHidden = !item.isAchieved
        
        print("ID ACHIEVED: \(item.idAchieved)")
        
        shareButton.rx.tap
            .map { item.idAchieved ?? "" }
            .bind(to: item.viewModel.input.shareI)
            .disposed(by: bag)
        
        disposeBag = bag
    }
}
