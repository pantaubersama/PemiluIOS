//
//  PublishChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import TwitterKit

class PublishChallengeController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var promoteView: PromoteView!
    @IBOutlet weak var challengeDetail: ChallengeDetailView!
    @IBOutlet weak var footerProfileView: FooterProfileView!
    @IBOutlet weak var constraintPromote: NSLayoutConstraint!
    @IBOutlet weak var constraintChallenge: NSLayoutConstraint!
    @IBOutlet weak var headerTantanganView: HeaderTantanganView!
    
    var viewModel: PublishChallengeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    var tantanganType: Bool = false
    private var twitterState: Bool? = false
    private var facebookState: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        title  = tantanganType ? "Preview" : "Promote Your Challenge"
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        promoteView.switchTwitter.rx.value
            .bind(to: viewModel.input.twitterI)
            .disposed(by: disposeBag)
        
        promoteView.switchFacebook.rx.value
            .bind(to: viewModel.input.facebookI)
            .disposed(by: disposeBag)
        
        viewModel.output.meO
            .do(onNext: { [unowned self] (user) in
                if let thumb = user.avatar.thumbnailSquare.url {
                    self.headerTantanganView.avatar.af_setImage(withURL: URL(string: thumb)!)
                }
                self.headerTantanganView.lblFullName.text = user.fullName
                self.headerTantanganView.lblUsername.text = "@\(user.username ?? "")"
                self.promoteView.configure(type: self.tantanganType, data: user)
                self.twitterState = user.twitter
                self.facebookState = user.facebook
            })
            .drive()
            .disposed(by: disposeBag)
        
        // TODO: Check twitter is connect or not
        // if connect then show composer tweet
        viewModel.output.twitterO
            .do(onNext: { [unowned self] (value) in
                print("Value twitter: \(value)")
                switch value {
                case true:
                    if self.twitterState == true {
                        if let username: String? = UserDefaults.Account.get(forKey: .usernameTwitter) {
                            switch self.tantanganType {
                            case true:
                                self.promoteView.contentTwitter.text = "Ayo undang langsung teman Twittermu untuk berdebat!\n\n\(username ?? "")"
                            case false:
                                self.promoteView.contentTwitter.text = "Tweet tantangan kamu sekarang. Undang temanmu untuk berdebat di sini.\n\n\(username ?? "")"
                            }
                        }
                    } else {
                        // must login then show composer again
                        self.viewModel.input.twitterLoginI.onNext(())
                    }
                case false:
                    switch self.tantanganType {
                    case true:
                        self.promoteView.contentTwitter.text = "Ayo undang langsung teman Twittermu untuk berdebat!"
                    case false:
                        self.promoteView.contentTwitter.text = "Tweet tantangan kamu sekarang. Undang temanmu untuk berdebat di sini."
                    }
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        // TODO: Check facebook is connect or not
        // if connect then show composer facebook
        viewModel.output.facebookO
            .do(onNext: { [unowned self] (value) in
                print("Value facebook: \(value)")
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.twitterLoginO
            .do(onNext: { [unowned self] (_) in
//                self.twitterState = value
                self.viewModel.input.refreshI.onNext(())
            })
            .drive()
            .disposed(by: disposeBag)
        
        
        viewModel.input.refreshI.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}

extension PublishChallengeController {
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }

}
