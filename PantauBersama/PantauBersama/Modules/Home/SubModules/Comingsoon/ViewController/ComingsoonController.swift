//
//  ComingsoonController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 06/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Lottie
import WebKit

class ComingsoonController: UIViewController {

    @IBOutlet weak var navbar: Navbar!
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var pantau: UIButton!
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var instagram: UIButton!
    @IBOutlet weak var twitter: UIButton!
    
    var viewModel: ComingsoonViewModel!

    private var landingAnimation: LOTAnimationView?
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Lottie
        landingAnimation = LOTAnimationView(name: "coming-soon-coffee")
        landingAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        landingAnimation!.contentMode = .scaleAspectFill
        landingAnimation!.frame = lottieView.bounds
        lottieView.addSubview(landingAnimation!)
        landingAnimation!.loopAnimation = true
        landingAnimation!.play(fromProgress: 0,
                               toProgress: 1.0,
                               withCompletion: nil)
        
        pantau.rx.tap
            .bind(to: viewModel.input.pantauI)
            .disposed(by: disposeBag)
        
        facebook.rx.tap
            .bind(to: viewModel.input.facebookI)
            .disposed(by: disposeBag)
        
        instagram.rx.tap
            .bind(to: viewModel.input.instagramI)
            .disposed(by: disposeBag)
        
        twitter.rx.tap
            .bind(to: viewModel.input.twitterI)
            .disposed(by: disposeBag)
        
        navbar.profile.rx.tap
            .bind(to: viewModel.input.profileI)
            .disposed(by: disposeBag)
        
        navbar.search.rx.tap
            .bind(to: viewModel.input.searchI)
            .disposed(by: disposeBag)
        
        navbar.note.rx.tap
            .bind(to: viewModel.input.noteI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.pantauO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.facebookO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.instagramO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.twitterO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.profileO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.searchO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.noteO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                if let thumbnail = user.avatar.thumbnail.url {
                    self.navbar.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        viewModel.input.viewWillAppearI.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
}
