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
        
        pantau.addTarget(self, action: #selector(handlePantau(sender:)), for: .touchUpInside)
        facebook.addTarget(self, action: #selector(handleFacebook(sender:)), for: .touchUpInside)
        twitter.addTarget(self, action: #selector(handleTwitter(sender:)), for: .touchUpInside)
        instagram.addTarget(self, action: #selector(handleInstagram(sender:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
 
    @objc private func handlePantau(sender: UIButton) {
        let url = "https://pantaubersama.com"
        let viewController = WKWebviewCustom()
        viewController.url = url
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func handleFacebook(sender: UIButton) {
        let url = "https://www.facebook.com/Pantau-Bersama-735930099884846/"
        let viewController = WKWebviewCustom()
        viewController.url = url
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func handleTwitter(sender: UIButton) {
        let url = "https://twitter.com/pantaubersama"
        let viewController = WKWebviewCustom()
        viewController.url = url
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func handleInstagram(sender: UIButton) {
        let url = "https://www.instagram.com/pantaubersama/"
        let viewController = WKWebviewCustom()
        viewController.url = url
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
