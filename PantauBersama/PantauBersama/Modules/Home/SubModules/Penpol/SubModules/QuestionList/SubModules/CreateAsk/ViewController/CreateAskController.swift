//
//  CreateAskController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class CreateAskController: UIViewController {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbFullname: Label!
    @IBOutlet weak var tvQuestion: UITextView!
    @IBOutlet weak var lbQuestionLimit: Label!
    var viewModel: CreateAskViewModel!
    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buat Pertanyaan"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(image: #imageLiteral(resourceName: "icDoneRed"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = done
        navigationController?.navigationBar.configure(with: .white)
        tvQuestion.delegate = self
        
        // MARK
        // bind View Model
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        done.rx.tap
            .bind(to: viewModel.input.createTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
        
        let a = viewModel.output.userData
        a.drive (onNext: { [weak self]user in
            guard let weakSelf = self else { return }
            // TODO: set avatar when user have avatar property
//            weakSelf.ivAvatar.show(fromURL: <#T##String#>)
            weakSelf.lbFullname.text = (user?.user.firstName ?? "") + " " + (user?.user.lastName ?? "")
        })
        .disposed(by: disposeBag)
        
        tvQuestion.rx.text
            .orEmpty
            .map { "\($0.count)/260" }
            .asDriverOnErrorJustComplete()
            .drive(lbQuestionLimit.rx.text)
            .disposed(by: disposeBag)
        
        let value = BehaviorRelay<String>(value: "")
        
        tvQuestion.rx.text
            .orEmpty
            .bind(to: viewModel.input.questionInput)
            .disposed(by: disposeBag)
        
        value
            .asObservable()
            .subscribe { text in
                print("this is the text \(text)")
            }
            .disposed(by: disposeBag)
    }

}

extension CreateAskController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 261
    }
}
