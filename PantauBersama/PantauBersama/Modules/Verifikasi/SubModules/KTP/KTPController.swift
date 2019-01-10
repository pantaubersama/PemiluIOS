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
import RxSwift
import RxCocoa

class KTPController: UIViewController {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var buttonLanjut: Button!
    
    private var ktpAnimation: LOTAnimationView?
    
    var viewModel: KTPViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
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
        
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        buttonLanjut.rx.tap
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
extension KTPController: ICameraController {
    func didFinishWith(image: UIImage) {
        self.viewModel.input.photoI.onNext(image)
    }
}
