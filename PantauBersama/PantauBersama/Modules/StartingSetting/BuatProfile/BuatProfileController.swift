//
//  BuatProfileController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class BuatProfileController: UIViewController {

    var viewModel: BuatProfileViewModel!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var buttonAvatar: Button!
    @IBOutlet weak var fullName: TextField!
    @IBOutlet weak var username: TextField!
    @IBOutlet weak var desc: TextField!
    @IBOutlet weak var location: TextField!
    @IBOutlet weak var education: TextField!
    @IBOutlet weak var occupation: TextField!
    @IBOutlet weak var nextButton: Button!
    
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buat Profilmu"
        navigationController?.navigationBar.configure(with: .white)
        
        nextButton.rx.tap
            .bind(to: viewModel.input.doneI)
            .disposed(by: disposeBag)
        
        fullName.rx.text
            .orEmpty
            .bind(to: viewModel.input.fullNameI)
            .disposed(by: disposeBag)
        
        username.rx.text
            .orEmpty
            .bind(to: viewModel.input.usernameI)
            .disposed(by: disposeBag)
        
        
        desc.rx.text
            .orEmpty
            .bind(to: viewModel.input.decsI)
            .disposed(by: disposeBag)
        
        location.rx.text
            .orEmpty
            .bind(to: viewModel.input.locationI)
            .disposed(by: disposeBag)
        
        education.rx.text
            .orEmpty
            .bind(to: viewModel.input.educationI)
            .disposed(by: disposeBag)
        
        occupation.rx.text
            .orEmpty
            .bind(to: viewModel.input.occupationI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                if let thumbnail = user.avatar.thumbnailSquare.url {
                    self.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
                self.fullName.text = user.fullName
                self.username.text = user.username
                self.desc.text = user.about
                self.location.text = user.location
                self.education.text = user.education
                self.occupation.text = user.occupation
            })
            .disposed(by: disposeBag)
        
        buttonAvatar.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                let controller = UIImagePickerController()
                controller.sourceType = .photoLibrary
                controller.delegate = self
                self.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.avatarO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.done
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.isEnabled
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.nextButton.backgroundColor = enable ? Color.primary_red : Color.grey_one
            })
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
}

extension BuatProfileController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else { return }
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.avatar.image = image
                self.viewModel.input.avatarI.onNext(image)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.avatar.image = image
                self.viewModel.input.avatarI.onNext(image)
            }
        })
    }
}
