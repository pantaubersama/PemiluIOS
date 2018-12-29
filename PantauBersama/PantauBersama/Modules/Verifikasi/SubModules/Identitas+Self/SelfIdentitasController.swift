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
import RxCocoa
import RxSwift

class SelfIdentitasController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonLanjut: Button!
    
    private var selfieIdentitas: LOTAnimationView?
    
    private let disposeBag = DisposeBag()
    
    var viewModel: ISelfIdentitasViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        
        // MARK:- Lottie
        selfieIdentitas = LOTAnimationView(name: "selfie-id-card")
        selfieIdentitas!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selfieIdentitas!.contentMode  = .scaleAspectFit
        selfieIdentitas!.frame = lottieView.bounds
        lottieView.addSubview(selfieIdentitas!)
        selfieIdentitas!.loopAnimation = true
        selfieIdentitas!.play(fromProgress: 0,
                                 toProgress: 1.0,
                                 withCompletion: nil)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        buttonLanjut.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                let controller = CameraController()
                controller.type = .selfKtp
                controller.delegate = self
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.photoO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.errorTrackerO
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
extension SelfIdentitasController: ICameraController {
    func didFinishWith(image: UIImage) {
        print("Gambar: \(image.jpegData(compressionQuality: 1.0))")
        self.viewModel.input.photoI.onNext(image)
    }
}
