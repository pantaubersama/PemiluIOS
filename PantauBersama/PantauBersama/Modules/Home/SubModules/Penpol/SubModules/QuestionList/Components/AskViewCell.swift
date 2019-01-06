//
//  AskViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Common
import Lottie

class AskViewCell: UITableViewCell, IReusableCell  {
    struct Input {
        let viewModel: QuestionViewModel
        let question: QuestionModel
    }

    private(set) var disposeBag = DisposeBag()
    
    @IBOutlet weak var voteActionView: UIView!
    @IBOutlet weak var lbBody: Label!
    @IBOutlet weak var lbCreatedAt: Label!
    @IBOutlet weak var lbAbout: Label!
    @IBOutlet weak var lbFullname: Label!
    @IBOutlet weak var lbVoteCount: Label!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var voteButton: ImageButton!
    
    lazy private var voteAnimation: LOTAnimationView = {
        let voteAnimation = LOTAnimationView(name: "upvote")
        voteAnimation.translatesAutoresizingMaskIntoConstraints = false
        voteAnimation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        voteAnimation.contentMode = .center
        voteAnimation.frame = voteButton.bounds
        voteAnimation.loopAnimation = false
        
        return voteAnimation
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        voteActionView.insertSubview(voteAnimation, at: 0)
        
        configureConstraint()
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            voteAnimation.topAnchor.constraint(equalTo: voteActionView.topAnchor),
            voteAnimation.leadingAnchor.constraint(equalTo: voteActionView.leadingAnchor),
            voteAnimation.bottomAnchor.constraint(equalTo: voteActionView.bottomAnchor),
            voteAnimation.trailingAnchor.constraint(equalTo: voteActionView.trailingAnchor)
            ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivAvatar.image = #imageLiteral(resourceName: "icDummyPerson")
        voteAnimation.stop()
        disposeBag = DisposeBag()
    }
    
    func configureCell(item: Input) {
        ivAvatar.show(fromURL: item.question.user.avatar.thumbnailSquare.url)
        lbFullname.text = item.question.user.fullName
        lbAbout.text = item.question.user.about
        lbBody.text = item.question.body
        lbCreatedAt.text = item.question.createdAt.id
        lbVoteCount.text = item.question.formatedLikeCount
        
        if item.question.isLiked {
            voteAnimation.play(fromProgress: 1, toProgress: 1, withCompletion: nil)
        }
        
        voteButton.rx.tap
            .map({ item.question })
            .bind(onNext: { (questionModel) in
                if questionModel.isLiked { return } // terminate process when user already liked this questionModel
                self.lbVoteCount.text = "\(questionModel.likeCount + 1)"
                self.voteAnimation.play(completion: { (finished) in
                    if finished {
                        item.viewModel.input.voteTrigger.onNext(questionModel)
                    }
                })
            })
            .disposed(by: disposeBag)
        
        moreButton.rx.tap
            .map({ item.question })
            .bind(to: item.viewModel.input.moreTrigger)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .map({ item.question })
            .bind(to: item.viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
    }
}
