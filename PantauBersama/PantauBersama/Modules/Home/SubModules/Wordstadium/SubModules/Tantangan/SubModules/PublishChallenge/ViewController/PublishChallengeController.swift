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
import FBSDKLoginKit
import Common
import FacebookShare

class PublishChallengeController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var promoteView: PromoteView!
    @IBOutlet weak var challengeDetail: ChallengeDetailView!
    @IBOutlet weak var footerProfileView: FooterProfileView!
    @IBOutlet weak var constraintPromote: NSLayoutConstraint!
    @IBOutlet weak var constraintChallenge: NSLayoutConstraint!
    @IBOutlet weak var headerTantanganView: HeaderTantanganView!
    @IBOutlet weak var btnPublish: Button!
    
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
        
        btnPublish.rx.tap
            .bind(to: viewModel.input.publishI)
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
                if let valueTwitter = user.twitter {
                    self.viewModel.input.twitterI.onNext(valueTwitter)
                }
                if let valueFacebook = user.facebook {
                    self.viewModel.input.facebookI.onNext(valueFacebook)
                }
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
                switch value {
                case true:
                    if self.facebookState == true {
                        if let username: String? = UserDefaults.Account.get(forKey: .usernameFacebook) {
                            self.promoteView.contentFacebook.text = "Post tantangan debatmu melalui Facebook. Undang temanmu untuk berdebat di sini.\n\n\(username ?? "")"
                        }
                    } else {
                        // TODO: Login Facebook
                        let manager: FBSDKLoginManager = FBSDKLoginManager()
                        manager.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { [weak self] (result, error) in
                            if error != nil {
                                
                            }
                            guard let result = result else { return }
                            if result.isCancelled == true {
                                
                            } else {
                                guard let token = result.token.tokenString else { return }
                                self?.viewModel.input.facebookLoginI.onNext(token)
                                self?.viewModel.input.facebookGraphI.onNext(())
                            }
                        })
                    }
                case false:
                    self.promoteView.contentFacebook.text = "Post tantangan debatmu melalui Facebook. Undang temanmu untuk berdebat di sini."
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.twitterLoginO
            .do(onNext: { [unowned self] (_) in
                self.viewModel.input.refreshI.onNext(())
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.facebookLoginO
            .do(onNext: { [unowned self] (_) in
                self.viewModel.input.refreshI.onNext(())
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.facebookGraphO
            .do(onNext: { (n,_,_,_,_) in
                if let username = n {
                    UserDefaults.Account.set("Connected as \(username)", forKey: .usernameFacebook)
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.input.refreshI.onNext(())
        
        viewModel.output.enableO
            .do(onNext: { [unowned self] (enable) in
                  self.btnPublish.backgroundColor = enable ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.9253990054, green: 0.9255540371, blue: 0.925378561, alpha: 1)
            })
            .drive(btnPublish.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.publishO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.shareFacebookO
            .do(onNext: { [unowned self] (s) in
                let content = LinkShareContent(url: URL(string: "\(AppContext.instance.infoForKey("URL_WEB_SHARE"))/share/wordstadium?type=open_challenge&challenge_id=\(s)")!)
                do {
//                    try ShareDialog.show(from: self, content: content)
                    try ShareDialog.show(from: self, content: content, completion: { (result) in
                        print("Result facebook \(result)")
                        self.viewModel.input.successI.onNext(())
                    })
                } catch {
                    
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.successO
            .drive()
            .disposed(by: disposeBag)
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
