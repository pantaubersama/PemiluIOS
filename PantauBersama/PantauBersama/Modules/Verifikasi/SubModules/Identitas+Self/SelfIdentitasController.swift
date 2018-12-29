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
        selfieIdentitas!.contentMode  = .scaleAspectFill
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
                let controller = UIImagePickerController()
                controller.sourceType = .camera
                controller.delegate = self
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
}


extension SelfIdentitasController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else { return }
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                print(image.debugDescription)
            } else if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                print(image.debugDescription)
            }
        })
    }
}
