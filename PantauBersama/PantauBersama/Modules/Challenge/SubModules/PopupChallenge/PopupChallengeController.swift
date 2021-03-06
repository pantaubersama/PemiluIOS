//
//  PopupChallengeController2.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 27/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import Networking

class PopupChallengeController: UIViewController {
    @IBOutlet weak var stackComment: UIStackView!
    @IBOutlet weak var btnBack: Button!
    @IBOutlet weak var btnConfirm: Button!
    @IBOutlet weak var lblInfo: Label!
    @IBOutlet weak var tvReason: UITextView!
    
    private let disposeBag = DisposeBag()
    
    var viewModel: PopupChallengeViewModel!
    var type: PopupChallengeType = .default
    var data: Challenge!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnBack.rx.tap
            .bind(to: viewModel.input.cancelI)
            .disposed(by: disposeBag)
        
        btnConfirm.rx.tap
            .bind(to: viewModel.input.acceptI)
            .disposed(by: disposeBag)
        
        self.configure(data: self.data, type: self.type)
        
        tvReason.text = "Tulis di sini..."
        tvReason.textColor = .lightGray
        
        tvReason.rx.didBeginEditing.bind { [unowned self] in
            if self.tvReason.textColor == .lightGray {
                self.tvReason.text = nil
                self.tvReason.textColor = Color.primary_black
            }
        }.disposed(by: disposeBag)
        
        tvReason.rx.didEndEditing.bind { [unowned self] in
            if self.tvReason.text.isEmpty {
                self.tvReason.text = "Tulis di sini..."
                self.tvReason.textColor = .lightGray
            }
        }.disposed(by: disposeBag)
    }
    
    private func configure(data: Challenge, type: PopupChallengeType) {
        let challenger = data.audiences.filter({ $0.role == .challenger }).first
        switch type {
        case .acceptDirect:
            self.btnConfirm.setTitle("SETUJU", for: UIControlState())
            self.lblInfo.text = "Kamu akan menerima Direct Challenge\ndari @\(challenger?.username ?? "") untuk berdebat."
        case .refuseDirect:
            self.btnConfirm.setTitle("YA, TOLAK", for: UIControlState())
            self.btnConfirm.backgroundColor = #colorLiteral(red: 0.7424071431, green: 0.03536110744, blue: 0.1090037152, alpha: 1)
            self.stackComment.isHidden = false
            self.lblInfo.text = "Kamu akan menolak Direct Challenge\ndari @\(challenger?.username ?? "") untuk berdebat. Tulis pernyataan atau alasannya sebagai hak jawab penolakan kamu."
            self.tvReason.rx.text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: viewModel.input.reasonI)
                .disposed(by: disposeBag)
        case .acceptOpen:
            self.lblInfo.text = "Kamu akan menerima tantangan dari @\(challenger?.username ?? "") untuk berdebat sesuai dengan detail yang tertera. Tindakan ini tidak bisa dibatalkan.\nApakah kamu yakin?"
        case .acceptOpponentOpen(let audienceId):
            let opponents = data.audiences.filter({ $0.id == audienceId })
            let usernameOpponents = opponents.first?.username
            self.lblInfo.text = "Kamu akan mengkonfirmasi @\(usernameOpponents ?? "") sebagai lawan debat anda sesuai dengan detail yang tertera. Tindakan ini tidak bisa dibatalkan.\nApakah kamu yakin?"
        default:
            break
        }
    }

}
