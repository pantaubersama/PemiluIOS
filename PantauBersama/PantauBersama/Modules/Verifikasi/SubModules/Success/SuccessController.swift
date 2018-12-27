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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.configure(with: .transparent)
        
        // MARK:- Lottie
        successAnimation = LOTAnimationView(name: "validation-success")
        successAnimation!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        successAnimation!.contentMode  = .scaleAspectFill
        successAnimation!.frame = lottieView.bounds
        lottieView.addSubview(successAnimation!)
        successAnimation!.loopAnimation = true
        successAnimation!.play(fromProgress: 0,
                               toProgress: 1,
                               withCompletion: nil)
        
        buttonFinish.addTarget(self, action: #selector(handleFinish(sender:)), for: .touchUpInside)
    }
    
    @objc private func handleFinish(sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
