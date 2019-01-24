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
        let isMyAccount: Bool
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        if item.isAchieved == true {
            if let thumbnail = item.badges.image.thumbnail.url {
                iconBadges.af_setImage(withURL: URL(string: thumbnail)!)
            }
        } else {
            if let thumbnail = item.badges.imageGrey?.thumbnail.url {
                iconBadges.af_setImage(withURL: URL(string: thumbnail)!)
            }
        }
        nameBadges.text = item.badges.name
        descriptionBadges.text = item.badges.description
        nameBadges.textColor = item.isAchieved ? Color.primary_black : Color.grey_three
        descriptionBadges.textColor = item.isAchieved ? Color.primary_black : Color.grey_three
        
        shareButton.rx.tap
            .map { item.idAchieved ?? "" }
            .bind(to: item.viewModel.input.shareI)
            .disposed(by: bag)
        
        if item.isMyAccount == true {
            shareButton.isHidden = item.isAchieved ? false : true
        } else {
            shareButton.isHidden = true
        }
        
        disposeBag = bag
    }
}
