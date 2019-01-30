//
//  LinimasaCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

typealias LinimasaCellConfigured = CellConfigurator<LinimasaCell, LinimasaCell.Input>

class LinimasaCell: UITableViewCell  {
    
    @IBOutlet weak var avatar: CircularUIImageView!
    @IBOutlet weak var name: Label!
    @IBOutlet weak var content: Label!
    @IBOutlet weak var titleTeam: Label!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var more: UIButton!
    @IBOutlet weak var username: Label!
    @IBOutlet weak var contentImageOne: UIImageView!
    @IBOutlet weak var contentImageTwo: UIImageView!
    @IBOutlet weak var containerMedia: RoundView!
    @IBOutlet weak var constraintMedia: NSLayoutConstraint!
    
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}

extension LinimasaCell: IReusableCell {
    
    struct Input {
        let viewModel: PilpresViewModel
        let feeds: Feeds
    }
    
    func configureCell(item: Input) {
        let feeds = item.feeds
        let bag = DisposeBag()
        
        configure(data: feeds)
        
        more.rx.tap
            .map({ feeds })
            .bind(to: item.viewModel.input.moreTrigger)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
    func configure(data: Feeds) {
        name.text = data.account.name
        let date = data.createdAtWord.id
        username.text = "@\(data.account.username) • \(date)"
        content.text = data.source.text
        titleTeam.text = "Disematkan dari \(data.team.title)"
        
        if let avatarUrl = data.account.profileImageUrl {
            avatar.af_setImage(withURL: URL(string: avatarUrl)!)
        }

        if let thumbnailUrl = data.team.avatar {
            thumbnail.af_setImage(withURL: URL(string: thumbnailUrl)!)
        }
        
        if let mediaCount = data.source.media?.count {
            if mediaCount > 1 {
                if let sourceContentOne = data.source.media?[0], let sourceContentTwo = data.source.media?[1] {
                    contentImageOne.af_setImage(withURL: URL(string: sourceContentOne)!)
                    contentImageTwo.af_setImage(withURL: URL(string: sourceContentTwo)!)
                    constraintMedia.constant = 140.0
                }
            } else if mediaCount == 1, let sourceContentOne = data.source.media?[0] {
                contentImageTwo.isHidden = true
                contentImageOne.af_setImage(withURL: URL(string: sourceContentOne)!)
                constraintMedia.constant = 140.0
            }
        } else {
            constraintMedia.constant = 0.0
        }
    }
    
}
