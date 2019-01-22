//
//  SuccessController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Lottie
import RxCocoa
import RxSwift

class SuccessController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonFinish: Button!
    
    private var successAnimation: LOTAnimationView?
    
    private let disposeBag = DisposeBag()
    var viewModel: SuccessViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.configure(with: .transparent)
        
        // MARK:- Lottie
        successAnimation = LOTAnimationView(name: "validation-success")
        successAnimation!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        successAnimation!.contentMode  = .scaleAspectFill
        successAnimation!.frame = lottieView.bounds
        lottieView.addSubview(successAnimation!)
        successAnimation!.loopAnimation = false
        successAnimation!.play(fromProgress: 0,
                               toProgress: 1,
                               withCompletion: nil)
        
        buttonFinish.rx.tap
            .bind(to: viewModel.input.finishI)
            .disposed(by: disposeBag)
        
        viewModel.output.finishO
            .drive()
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
