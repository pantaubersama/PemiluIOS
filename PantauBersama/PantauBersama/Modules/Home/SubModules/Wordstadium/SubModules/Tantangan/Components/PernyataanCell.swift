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
import URLEmbeddedView

enum PernyataanLinkResult {
    case cancel
    case ok(String)
}


class PernyataanCell: UITableViewCell {
    
    @IBOutlet weak var lineStatus: UIView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var lblCounter: Label!
    @IBOutlet weak var tvPernyataan: UITextView!
    @IBOutlet weak var btnHint: UIButton!
    @IBOutlet weak var btnLink: Button!
    @IBOutlet weak var linkPreviewView: LinkPreviewView!
    @IBOutlet weak var statusBottom: UIImageView!
    
    @IBOutlet weak var contraintLinkPreview: NSLayoutConstraint!
    private var disposeBag: DisposeBag!
    
    let linkPreview = URLEmbeddedView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        linkPreview.prepareViewsForReuse()
        disposeBag = nil
    }
    
}

extension PernyataanCell: IReusableCell {
    
    struct Input {
        let viewModel: TantanganChallengeViewModel
        let status: Bool
        let content: String?
        let link: String?
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        
        lineStatus.backgroundColor = item.status ? #colorLiteral(red: 1, green: 0.5569574237, blue: 0, alpha: 1) : #colorLiteral(red: 0.7960169315, green: 0.7961130738, blue: 0.7959839106, alpha: 1)
        status.image = item.status ? #imageLiteral(resourceName: "checkDone") : #imageLiteral(resourceName: "checkUnactive")
        statusBottom.image = item.status ? nil : #imageLiteral(resourceName: "checkInactive")
        
        tvPernyataan.delegate = self
        if item.content == nil {
            tvPernyataan.text = "Tulis pernyataanmu di sini..."
            tvPernyataan.textColor = UIColor.lightGray
        } else {
            tvPernyataan.text = item.content
            tvPernyataan.textColor = Color.primary_black
        }
        
        if item.link == nil {
            item.viewModel.input.sourceLinkI.onNext((""))
            btnLink.setTitle("Sertakan link disini", for: .normal)
            btnLink.isHidden = false
        } else {
            btnLink.setTitle(item.link, for: .normal)
            btnLink.isHidden = true
            if let linkString = item.link {
                OGDataProvider.shared.fetchOGData(urlString: linkString, completion: { [unowned self] (data, error) in
                    if let _ = error {
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        self.linkPreviewView.lblLink.text = data.sourceUrl?.absoluteString
                        self.linkPreviewView.lblContent.text = data.siteName
                        self.linkPreviewView.lblDescContent.text = data.pageDescription
                        if let avatar = data.imageUrl?.absoluteString {
                            self.linkPreviewView.ivAvatarLink.af_setImage(withURL: URL(string: avatar)!)
                        }
                    })
                })
            }
            UIView.transition(with: self.linkPreviewView, duration: 0.4, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let `self` = self else { return }
                self.linkPreviewView.isHidden = false
                self.contraintLinkPreview.constant = 75.0
            })
        }
        
        linkPreviewView.btnCloseLink.rx.tap
            .do(onNext: { [unowned self] (_) in
                self.btnLink.isHidden = false
                self.btnLink.setTitle("Sertakan link disini", for: .normal)
                UIView.transition(with: self.linkPreviewView, duration: 0.4, options: .transitionCrossDissolve, animations: { [weak self] in
                    guard let `self` = self else { return }
                    self.linkPreviewView.isHidden = true
                    self.contraintLinkPreview.constant = 0.0
                })
            })
            .bind(to: item.viewModel.input.pernyataanLinkCancelI)
            .disposed(by: bag)
        
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
        
        btnLink.rx.tap
            .do(onNext: { [unowned self] (_) in
                OGImageProvider.shared.clearMemoryCache()
                OGImageProvider.shared.clearAllCache()
                OGDataProvider.shared.deleteOGData(urlString: item.link ?? "")
                self.linkPreviewView.ivAvatarLink.image = nil
            })
            .bind(to: item.viewModel.input.pernyataanLinkI)
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
