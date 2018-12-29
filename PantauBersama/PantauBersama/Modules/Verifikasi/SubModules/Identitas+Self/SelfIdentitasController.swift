//
//  SelfIdentitasController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Lottie
import Common

class SelfIdentitasController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonLanjut: Button!
    
    private var selfieIdentitas: LOTAnimationView?
    
    var viewModel: ISelfIdentitasViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(handleBack(sender:)))
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        
        // MARK:- Lottie
        selfieIdentitas = LOTAnimationView(name: "selfie-id-card")
        selfieIdentitas!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selfieIdentitas!.contentMode  = .scaleAspectFill
        selfieIdentitas!.frame = lottieView.bounds
        lottieView.addSubview(selfieIdentitas!)
        selfieIdentitas!.loopAnimation = true
        selfieIdentitas!.play(fromProgress: 0,
                                 toProgress: 1.0,
                                 withCompletion: nil)
        
        buttonLanjut.addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
    }
    
    @objc private func handleBack(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTap(sender: UIButton) {
        let vc = KTPController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
