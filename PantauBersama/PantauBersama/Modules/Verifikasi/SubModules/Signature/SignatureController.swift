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
import RxSwift
import RxCocoa

class SignatureController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var button: Button!
    
    private var signatureAnimation: LOTAnimationView?
    
    var viewModel: SignatureViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
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
                               toProgress: 1,
                               withCompletion: nil)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                let controller = CameraController()
                controller.delegate = self
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.photoO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
    
}

// MARK
// Handle camera delegate from camera controller
// next step will improve this system using OCR
// this system still using default camera to test API
extension SignatureController: ICameraController {
    func didFinishWith(image: UIImage) {
        print("Gambar: \(image.jpegData(compressionQuality: 1.0))")
        self.viewModel.input.photoI.onNext(image)
    }
}
