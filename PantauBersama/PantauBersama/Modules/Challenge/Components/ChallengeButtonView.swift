//
//  ChallengeButtonView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Lottie
import Networking
import RxSwift
import RxCocoa

@IBDesignable
class ChallengeButtonView: UIView {
    
    @IBOutlet weak var containerLike: UIView!
    @IBOutlet weak var btnShare: Button!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var containerLottie: UIView!
    @IBOutlet weak var btnLove: UIButton!
    @IBOutlet weak var lbLoveCount: Label!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var loveAnimation: LOTAnimationView = {
       let loveAnimation = LOTAnimationView(name: "love")
        loveAnimation.translatesAutoresizingMaskIntoConstraints = false
        loveAnimation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        loveAnimation.contentMode = .center
        loveAnimation.frame = containerLottie.bounds
        loveAnimation.loopAnimation = false
        return loveAnimation
    }()
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56.0)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerLottie.insertSubview(loveAnimation, at: 0)
        
        configureConstraint()
        
    }
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            self.loveAnimation.topAnchor.constraint(equalTo: containerLottie.topAnchor),
            self.loveAnimation.leftAnchor.constraint(equalTo: containerLottie.leftAnchor),
            self.loveAnimation.rightAnchor.constraint(equalTo: containerLottie.rightAnchor),
            self.loveAnimation.bottomAnchor.constraint(equalTo: containerLottie.bottomAnchor)
        ])
    }

    func configure(type: ChallengeType, viewModel: ChallengeViewModel, data: Challenge) {
        let bag = DisposeBag()
        switch type {
        case .done:
            containerLike.isHidden = false
            
            loveAnimation.play(fromProgress: data.isLiked ?? false ? 1 : 0, toProgress: data.isLiked ?? false ? 1 : 0, withCompletion: nil)
            lbLoveCount.text = "\(data.likeCount ?? 0)"
            btnLove.rx.tap
                .do(onNext: { [unowned self] (_) in
                    /// check condition model data is liked or not
                    self.loveAnimation.play(fromProgress: 0, toProgress: 1, withCompletion: nil)
                })
                .bind(to: viewModel.input.loveI)
                .disposed(by: bag)
            
        default:
            break
        }
        disposeBag = bag
    }
    
}
