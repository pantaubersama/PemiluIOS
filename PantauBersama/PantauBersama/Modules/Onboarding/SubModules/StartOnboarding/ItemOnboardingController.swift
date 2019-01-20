//
//  ItemOnboardingController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import Lottie
import Common

class ItemOnboardingController: UIViewController {
    
    @IBOutlet weak var containerLottie: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var desc: Label!
    
    var lotieAnimationView: LOTAnimationView?
    
    var item: OnboardingiItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerTitle.text = item.title
        desc.text = item.description
        
        // Lottie
        lotieAnimationView = LOTAnimationView(name: item.lottieAnimationView)
        lotieAnimationView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lotieAnimationView!.contentMode  = .scaleAspectFit
        lotieAnimationView!.frame = containerLottie.bounds
        containerLottie.addSubview(lotieAnimationView!)
        lotieAnimationView!.loopAnimation = true
        lotieAnimationView!.play(fromProgress: 0,
                              toProgress: 1.0,
                              withCompletion: nil)
    }
    
}

struct OnboardingiItem {
    let title: String
    let description: String
    let lottieAnimationView: String
}
