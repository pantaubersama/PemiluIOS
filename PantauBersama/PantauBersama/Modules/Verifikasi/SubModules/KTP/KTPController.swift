//
//  KTPController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Lottie
import Common

class KTPController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonLanjut: Button!
    
    private var ktpAnimation: LOTAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(handleBack(sender:)))
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK:- Lottie
        ktpAnimation = LOTAnimationView(name: "memfoto-idcard")
        ktpAnimation!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ktpAnimation!.contentMode  = .scaleAspectFill
        ktpAnimation!.frame = lottieView.bounds
        lottieView.addSubview(ktpAnimation!)
        ktpAnimation!.loopAnimation = true
        ktpAnimation!.play(fromProgress: 0,
                                 toProgress: 1,
                                 withCompletion: nil)
        
        buttonLanjut.addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
    }
    
    @objc private func handleBack(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTap(sender: UIButton) {
        let vc = SignatureController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
