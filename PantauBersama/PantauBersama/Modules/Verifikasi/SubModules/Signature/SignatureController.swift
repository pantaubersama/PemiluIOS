//
//  SignatureController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Lottie
import Common


class SignatureController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var button: Button!
    
    private var signatureAnimation: LOTAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(handleBack(sender:)))
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK:- Lottie
        signatureAnimation = LOTAnimationView(name: "upload-ttd")
        signatureAnimation!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        signatureAnimation!.contentMode  = .scaleAspectFill
        signatureAnimation!.frame = lottieView.bounds
        lottieView.addSubview(signatureAnimation!)
        signatureAnimation!.loopAnimation = true
        signatureAnimation!.play(fromProgress: 0,
                               toProgress: 0.5,
                               withCompletion: nil)
        
        button.addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
    }
    
    @objc private func handleBack(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTap(sender: UIButton) {
        let vc = SuccessController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
