//
//  DebatCommentController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class DebatCommentController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var staticNavigationBar: UINavigationBar!
    @IBOutlet weak var btnClose: UIBarButtonItem!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnSend: ImageButton!
    var viewModel: DebatCommentViewModel!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInputView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        staticNavigationBar.isTranslucent = true
        staticNavigationBar.barTintColor = .clear
        staticNavigationBar.setBackgroundImage(UIImage(), for: .default)
        staticNavigationBar.shadowImage = UIImage()
        staticNavigationBar.tintColor = .black
        
        btnClose.rx.tap
            .bind { [unowned self](_) in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // for dummy ui
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(DebatCommentCell.self)
    }
    
    private func configureInputView() {
        tvComment.text = "Tulis Komentar"
        tvComment.textColor = .lightGray
        
        tvComment.rx.didBeginEditing.bind { [unowned self]in
            if self.tvComment.textColor == .lightGray {
                self.tvComment.text = nil
                self.tvComment.textColor = Color.primary_black
            }
            }
            .disposed(by: disposeBag)
        
        tvComment.rx.didEndEditing.bind { [unowned self]in
            if self.tvComment.text.isEmpty {
                self.tvComment.text = "Tulis Komentar"
                self.tvComment.textColor = .lightGray
            }
            }
            .disposed(by: disposeBag)
    }
}

extension DebatCommentController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as DebatCommentCell
        if indexPath.row % 2 == 0 {
            cell.lbContent.text = "nice bangeeet \n jos gandos"
        } else {
            cell.lbContent.text = "argumen kontranya tidak nyambung. terlalu membawa subjektifitas yang tidak bisa dipakai buat diskusi yang membangun. saya tandai orang itu."
        }
        
        return cell
    }
}
