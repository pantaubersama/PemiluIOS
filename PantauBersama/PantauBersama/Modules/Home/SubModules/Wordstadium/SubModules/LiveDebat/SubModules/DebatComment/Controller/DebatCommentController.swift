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
import RxDataSources
import Networking
import IQKeyboardManagerSwift

class DebatCommentController: UIViewController {
    @IBOutlet weak var viewInputContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var staticNavigationBar: UINavigationBar!
    @IBOutlet weak var btnClose: UIBarButtonItem!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnSend: ImageButton!
    @IBOutlet weak var heightInput: NSLayoutConstraint!
    @IBOutlet weak var heightContainerInput: NSLayoutConstraint!
    var viewModel: DebatCommentViewModel!
    private let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    private let disposeBag = DisposeBag()
    private var animatedDataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Word>>!
    private var tableHeader: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableHeader.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        tableView.tableHeaderView = tableHeader
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(DebatCommentCell.self)
        tableView.addGestureRecognizer(tapGesture)
        
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        tapGesture.rx.event
            .subscribe(onNext: { [unowned self] (_) in
                self.tvComment.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        tvComment.delegate = self
        tvComment.isScrollEnabled = false
        textViewDidChange(tvComment)
        
        animatedDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Word>> (configureCell: { dataSouce, tableView, indexPath, word in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as DebatCommentCell
            cell.configureCell(item: DebatCommentCell.Input(word: word))
            return cell
        })
        
        viewModel.output.commentsO
            .map({ word in
                [AnimatableSectionModel(model: "Section", items: word.reversed())]
            })
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        
        btnSend.rx.tap
            .map({ self.tvComment.text.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ (content) -> Bool in
                return !content.isEmpty && self.tvComment.textColor != .lightGray
            })
            .do(onNext: { [unowned self](_) in
                self.tvComment.text = nil
                self.tvComment.isEditable = true
                self.textViewDidChange(self.tvComment)
            })
            .bind(to: self.viewModel.input.sendCommentI)
            .disposed(by: disposeBag)
        
        viewModel.output.loadCommentsO
            .drive()
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { [unowned self] (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height - (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextI)
            .disposed(by: disposeBag)
        
        viewModel.output.sendCommentO
//            .map({ word in
//                [AnimatableSectionModel(model: "Section", items: [word])]
//            })
            .drive(onNext: { [weak self] (_) in
                guard let `self` = self else { return  }
                self.tvComment.text = nil
                self.tvComment.isEditable = true
                self.textViewDidChange(self.tvComment)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.newCommentO
            .map({ word in
                [AnimatableSectionModel(model: "Section", items: [word])]
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.input.loadCommentI.onNext(())
        configureInputView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        staticNavigationBar.isTranslucent = true
        staticNavigationBar.barTintColor = .clear
        staticNavigationBar.setBackgroundImage(UIImage(), for: .default)
        staticNavigationBar.shadowImage = UIImage()
        staticNavigationBar.tintColor = .black
        
        /// Disable IQKeyboardManager
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        btnClose.rx.tap
            .bind { [unowned self](_) in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
//    private func scrollToBottom(animated: Bool = true) {
//        if (self.tableView.indexPathsForVisibleRows?.count ?? 0) != 0 {
//            self.tableView.scrollToRow(at: IndexPath(row: self.viewModel.output.commentsO.value.count - 1, section: 0), at: .bottom, animated: animated)
//        }
//    }
    
    private func configureInputView() {
        viewModel.output.viewTypeO
            .drive(onNext: { [unowned self]viewType in
                switch viewType {
                case .done, .participant:
                    self.viewInputContainer.isHidden = true
                    break
                default:
                    self.viewInputContainer.isHidden = false
                    break
                }
            })
            .disposed(by: disposeBag)
        
        tvComment.text = "Tulis Komentar"
        tvComment.textColor = .lightGray
        
        tvComment.rx.didBeginEditing.bind { [unowned self]in
            if self.tvComment.textColor == .lightGray {
                self.tvComment.text = nil
                self.tvComment.textColor = Color.primary_black
                self.textViewDidChange(self.tvComment)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// Enable IQKeyboardManager
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
}

extension DebatCommentController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        if estimateSize.height > 100 {
            heightInput.constant = 100
            heightContainerInput.constant = 120
            textView.isScrollEnabled = true
        } else {
            heightInput.constant = estimateSize.height
            heightContainerInput.constant = estimateSize.height + 20
            textView.isScrollEnabled = false
        }
    }
}
