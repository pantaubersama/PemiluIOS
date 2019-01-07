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

class ComingsoonController: UIViewController {

    @IBOutlet weak var navbar: Navbar!
    @IBOutlet weak var lottieView: UIView!
    
    private var landingAnimation: LOTAnimationView?
    
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
                               toProgress: 0.5,
                               withCompletion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
}
