//
//  PernyataanCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class PernyataanCell: UITableViewCell {
    
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var lblCounter: Label!
    @IBOutlet weak var tvPernyataan: UITextView!
    @IBOutlet weak var btnHint: UIButton!
    private var disposeBag: DisposeBag!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
}

extension PernyataanCell: IReusableCell {
    
    struct Input {
        let viewModel: OpenChallengeViewModel
        let status: Bool
        let content: String?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lineStatus.backgroundColor = item.status ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.7960169315, green: 0.7961130738, blue: 0.7959839106, alpha: 1)
        status.image = item.status ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        
        tvPernyataan.delegate = self
        if item.content == nil {
            tvPernyataan.text = "Tulis pernyataanmu di sini..."
            tvPernyataan.textColor = UIColor.lightGray
        } else {
            tvPernyataan.text = item.content
            tvPernyataan.textColor = Color.primary_black
        }
        
        tvPernyataan.rx.text
            .orEmpty
            .map { [unowned self] text in
                if self.tvPernyataan.textColor == UIColor.lightGray {
                    return "0/160"
                }
                return "\(text.count)/160"
            }
            .asDriverOnErrorJustComplete()
            .drive(lblCounter.rx.text)
            .disposed(by: bag)
        
        tvPernyataan.rx.text
            .orEmpty
            .bind(to: item.viewModel.input.pernyataanTextInput)
            .disposed(by: bag)
        
        btnHint.rx.tap
            .bind(to: item.viewModel.input.hintPernyataanI)
            .disposed(by: bag)
        
        tvPernyataan.rx.didEndEditing
            .map({ self.tvPernyataan.text })
            .bind(to: item.viewModel.input.statusPernyataan)
            .disposed(by: bag)
        
        disposeBag = bag
    }
    
}


extension PernyataanCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 161
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = Color.primary_black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tulis pernyataanmu di sini..."
            textView.textColor = UIColor.lightGray
        }
    }
}
