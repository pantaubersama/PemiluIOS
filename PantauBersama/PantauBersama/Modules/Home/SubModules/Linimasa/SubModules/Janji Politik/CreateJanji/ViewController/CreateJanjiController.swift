//
//  CreateJanjiController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common

class CreateJanjiController: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: Label!
    @IBOutlet weak var titleJanji: TextField!
    @IBOutlet weak var contentJanji: UITextView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textCount: Label!
    @IBOutlet weak var image: UIImageView!
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.sizeToFit()
        return bar
    }()
    
    var viewModel: ICreateJanjiViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Janji Politik"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.configure(with: .white)
        
        let unggah = UIBarButtonItem(image: #imageLiteral(resourceName: "outlineImage24Px"), style: .plain, target: nil, action: nil)
        let doneBar = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard(sender:)))
        unggah.tintColor = Color.primary_black
        toolbar.items = [unggah, doneBar]
        contentJanji.inputAccessoryView = toolbar
        
        contentJanji.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // MARK
        // Setup Editor
        // need editor custom
        setupEditorView()
        
        // MARK
        // bind View Model
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        done.rx.tap
            .bind(to: viewModel.input.doneI)
            .disposed(by: disposeBag)
        
        titleJanji.rx.text.orEmpty
            .bind(to: viewModel.input.titleI)
            .disposed(by: disposeBag)
        
        contentJanji.rx.text.orEmpty
            .bind(to: viewModel.input.bodyI)
            .disposed(by: disposeBag)
        
        unggah.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                let controller = UIImagePickerController()
                controller.sourceType = .photoLibrary
                controller.delegate = self
                self?.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.userDataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                
                self.name.text = user.fullName
                if let url = user.avatar.thumbnail.url {
                    self.avatar.af_setImage(withURL: URL(string: url)!)
                }
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.enableO
            .drive(done.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.actionO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                guard let alert = UIAlertController.alert(with: error) else { return }
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupEditorView() {
        contentJanji.text = "Berikan deskripsi atau detil lebih lanjut terkait Janji Politik yang akan disampaikan di kolom ini."
        contentJanji.textColor = UIColor.lightGray
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
    @objc private func dismissKeyboard(sender: UIBarButtonItem) {
        contentJanji.endEditing(true)
    }
}

extension CreateJanjiController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Berikan deskripsi atau detil lebih lanjut terkait Janji Politik yang akan disampaikan di kolom ini."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength =  textView.text.count + text.count - range.length
        
        textCount.text =  String(newLength) + "/160"

        return newLength < 160
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        if estimateSize.height > 200 {
            contentHeightConstraint.constant = 200
            textView.isScrollEnabled = true
        } else if estimateSize.height > 100 {
            contentHeightConstraint.constant = estimateSize.height
            textView.isScrollEnabled = false
        } else {
            contentHeightConstraint.constant = 100
            textView.isScrollEnabled = false
        }
    }
}

extension CreateJanjiController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else { return }
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.image.image = image
                self.viewModel.input.imageI.onNext(image)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.image.image = image
                self.viewModel.input.imageI.onNext(image)
            }
        })
    }
}

