//
//  OnboardingViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common
import Lottie

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonMulai: Button!
    @IBOutlet weak var buttonLewati: UIButton!
    
    var viewModel: OnboardingViewModel!
    private var landingAnimation: LOTAnimationView?
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonMulai.rx.tap
            .bind(to: viewModel.input.siginTrigger)
            .disposed(by: disposeBag)

        buttonLewati.rx.tap
            .bind(to: viewModel.input.bypassTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.siginSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.bypassSelected
            .drive()
            .disposed(by: disposeBag)
        
        // MARK: Lottie
        // Setting lottie background landing
        landingAnimation = LOTAnimationView(name: "landing-page-backround-mobile")
        landingAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        landingAnimation!.contentMode = .scaleAspectFill
        landingAnimation!.frame = lottieView.bounds
        lottieView.addSubview(landingAnimation!)
        landingAnimation!.loopAnimation = true
        landingAnimation!.play(fromProgress: 0,
                               toProgress: 0.5,
                               withCompletion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
