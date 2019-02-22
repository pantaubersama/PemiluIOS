//
//  LiveDebatController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift

class LiveDebatController: UIViewController {
    
    // UI view variable
    @IBOutlet weak var latestCommentView: UIStackView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var headerTitle: Button!
    @IBOutlet weak var btnSendComment: ImageButton!
    @IBOutlet weak var viewClapContainer: UIView!
    @IBOutlet weak var ivHeaderBackground: UIImageView!
    @IBOutlet weak var viewTimeContainer: UIStackView!
    @IBOutlet weak var btnCommentShow: UIButton!
    @IBOutlet weak var btnScroll: Button!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewDebat: UITableView!
    @IBOutlet weak var tvInputDebat: UITextView!
    @IBOutlet weak var tvInputComment: UITextView!
    @IBOutlet weak var imageVs: UIImageView!
    @IBOutlet weak var viewInputContainer: UIView!
    @IBOutlet weak var viewComentarContainer: UIView!
    @IBOutlet weak var btnDetailDebat: Button!
    @IBOutlet weak var constraintTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInputViewHeight: NSLayoutConstraint!
    private lazy var titleView = Button()
    
    // ui flag variable
    private var isKeyboardAppear = false
    private var isCommentAppear = false
    
    
    var viewModel: LiveDebatViewModel!
    private lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        // config input behavior
        configureInputView()
        
        // config button scroll behavior
        configureScrollButton()
        
        // for dummy ui
        tableViewDebat.dataSource = self
        tableViewDebat.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        tableViewDebat.isScrollEnabled = false
        tableViewDebat.estimatedRowHeight = 44.0
        tableViewDebat.rowHeight = UITableView.automaticDimension
        tableViewDebat.registerReusableCell(ArgumentLeftCell.self)
        tableViewDebat.registerReusableCell(ArgumentRightCell.self)
        
        // configure scrolling behavior for header to response
        scrollView.rx.contentOffset
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self](point) in
                self.configureCollapseNavbar(y: point.y, collaspingY: 40.0)
            }).disposed(by: disposeBag)
        
        // listen whether the last cell displayed or not
        // if yes, then rotate the btnScroll and set tag to 1 (0 = scroll to bottom, 1 = scroll to top)
        tableViewDebat.rx.willDisplayCell
            .map({ $0.indexPath })
            .map({ $0.row == 19 })
            .bind { [unowned self](isOnBottom) in
                self.btnScroll.tag = isOnBottom ? 0 : 1
                self.btnScroll.rotate(degree: isOnBottom ? 180 : 0)
            }
            .disposed(by: disposeBag)
        
        // open debat detail when tapped
        btnDetailDebat.rx.tap
            .bind(to: viewModel.input.launchDetailTrigger)
            .disposed(by: disposeBag)
        
        // open debat comment when tapped
        btnCommentShow.rx.tap
            .bind(to: viewModel.input.showCommentTrigger)
            .disposed(by: disposeBag)
        
        // drive
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.launchDetail
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.showComment
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.menu
            .asObservable()
            .flatMapLatest({ [unowned self]_ -> Observable<String> in
                return Observable.create({ (observer) -> Disposable in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let salinTautan = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext("salin")
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext("bagigan")
                        observer.on(.completed)
                    })
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alert.addAction(salinTautan)
                    alert.addAction(bagikan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.selectMenuTrigger)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForKeyboardEvent()
        configureNavbar()
        configureTitleView()
        
        viewModel.output.viewType
        .drive(onNext: { [weak self](viewType) in
            guard let weakSelf = self else { return }
            weakSelf.configureViewType(viewType: viewType)
        })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeForKeyboardEvent()
        titleView.removeFromSuperview()
    }
    
    //MARK: selector
    @objc func keyboardWillAppear(notification: NSNotification) {
        isKeyboardAppear = true
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // move input view above the keyboard and collapse the header
        UIView.animate(withDuration: 0.4) { [unowned self] in
            self.bottomMargin.constant += keyboardFrame.height
//            self.constraintInputViewBottom.constant += keyboardFrame.height
            self.view.layoutIfNeeded()
        }
        collapseHeader()
    }
    
    @objc func keyboardWillDisappear() {
        isKeyboardAppear = false
        // bring input view down
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.bottomMargin.constant = 5
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: private func
    private func subscribeForKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeForKeyboardEvent() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureViewType(viewType: DebatViewType) {
        switch viewType {
        case .watch:
            latestCommentView.isHidden = true
            viewComentarContainer.isHidden = false
            viewInputContainer.isHidden = true
            constraintTableViewBottom.constant = 0
            viewTimeContainer.isHidden = true
            constraintInputViewHeight.constant = 50
            headerTitle.setTitle("LIVE NOW", for: .normal)
            headerTitle.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
            titleView.setTitle("LIVE NOW", for: .normal)
            titleView.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
            break
        case .myTurn:
            latestCommentView.isHidden = true
            viewComentarContainer.isHidden = true
            viewInputContainer.isHidden = false
            constraintTableViewBottom.constant = 105
            viewTimeContainer.isHidden = false
            constraintInputViewHeight.constant = 105
            headerTitle.setTitle("LIVE NOW", for: .normal)
            headerTitle.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
            titleView.setTitle("LIVE NOW", for: .normal)
            titleView.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
            break
        case .theirTurn:
            latestCommentView.isHidden = false
            viewComentarContainer.isHidden = false
            viewInputContainer.isHidden = true
            constraintTableViewBottom.constant = 0
            viewTimeContainer.isHidden = false
            constraintInputViewHeight.constant = 50
            headerTitle.setTitle("LIVE NOW", for: .normal)
            headerTitle.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
            titleView.setTitle("LIVE NOW", for: .normal)
            titleView.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
            break
        case .done:
            ivHeaderBackground.image = #imageLiteral(resourceName: "bgWordstadiumDone")
            latestCommentView.isHidden = false
            viewTimeContainer.isHidden = true
            viewClapContainer.isHidden = false
            constraintTableViewBottom.constant = 0
            constraintInputViewHeight.constant = 50
            headerTitle.setTitle("Result", for: .normal)
            headerTitle.setImage(UIImage(), for: .normal)
            titleView.setImage(UIImage(), for: .normal)
            titleView.setTitle("Result", for: .normal)
            break
        }
    }
    
    private func configureScrollButton() {
        self.btnScroll.tag = 1
        btnScroll.rx.tap
            .bind(onNext: { [unowned self] in
                // tag 0 = scroll to top, tag 1 = scroll to bottom
                if self.btnScroll.tag == 1 {
                    self.btnScroll.tag = 0
                    self.collapseHeader()
                    self.tableViewDebat.scrollToRow(at: IndexPath(row: 19, section: 0), at: .top, animated: true)
                } else {
                    self.btnScroll.tag = 1
                    self.tableViewDebat.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    
                    if !self.isKeyboardAppear {
                        self.expandHeader()
                    }
                }
                
                
            })
            .disposed(by: disposeBag)
    }
    
    private func configureInputView() {
        // setup placeholder
        tvInputDebat.text = "Tulis argumen kamu disini"
        tvInputDebat.textColor = .lightGray
        
        tvInputDebat.rx.didBeginEditing.bind { [unowned self]in
            if self.tvInputDebat.textColor == .lightGray {
                self.tvInputDebat.text = nil
                self.tvInputDebat.textColor = Color.primary_black
            }
            }
            .disposed(by: disposeBag)
        
        tvInputDebat.rx.didEndEditing.bind { [unowned self]in
            if self.tvInputDebat.text.isEmpty {
                self.tvInputDebat.text = "Tulis Komentar"
                self.tvInputDebat.textColor = .lightGray
            }
            }
            .disposed(by: disposeBag)
        
        tvInputComment.text = "Tulis Komentar"
        tvInputComment.textColor = .lightGray
        
        tvInputComment.rx.didBeginEditing.bind { [unowned self]in
            self.btnSendComment.isHidden = false
            if self.tvInputComment.textColor == .lightGray {
                self.tvInputComment.text = nil
                self.tvInputComment.textColor = Color.primary_black
            }
        }
        .disposed(by: disposeBag)
        
        tvInputComment.rx.didEndEditing.bind { [unowned self]in
            self.btnSendComment.isHidden = true
            if self.tvInputComment.text.isEmpty {
                self.tvInputComment.text = "Tulis Komentar"
                self.tvInputComment.textColor = .lightGray
            }
        }
        .disposed(by: disposeBag)
        
        
    }
    
    private func configureNavbar() {
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = back
        
        let more = UIBarButtonItem(image: #imageLiteral(resourceName: "icMoreVerticalWhite"), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = more
        
        self.navigationController?.navigationBar.configure(with: .transparent)
        
        more.rx.tap
            .bind(to: viewModel.input.showMenuTrigger)
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
    }
    
    private func configureTitleView() {
        // titleView used Button for compatibility with icon
        titleView.isHidden = true
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.typeButton = "bold"
        titleView.fontSize = 14
        titleView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        titleView.isUserInteractionEnabled = false
        
        if let navBar = self.navigationController?.navigationBar {
            navBar.addSubview(titleView)
            NSLayoutConstraint.activate([
                titleView.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
                titleView.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
                titleView.topAnchor.constraint(equalTo: navBar.topAnchor),
                titleView.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
                titleView.widthAnchor.constraint(equalToConstant: 100)
                ])
        }
    }
    
    private func configureCollapseNavbar(y: CGFloat, collaspingY: CGFloat) {
        // listen for scrollView y position,
        
        if y > collaspingY && self.navigationController?.navigationBar.barTintColor != Color.secondary_orange { // collapsed
            self.tableViewDebat.isScrollEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.navigationBar.barTintColor = Color.secondary_orange
                self.navigationController?.navigationBar.backgroundColor = Color.secondary_orange
                self.imageVs.alpha = 0.0
            })
            
            self.titleView.isHidden = false
        } else if y < collaspingY && self.navigationController?.navigationBar.barTintColor != UIColor.clear { // expanded
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.configure(with: .transparent)
                self.imageVs.alpha = 1.0
            })
            
            self.titleView.isHidden = true
        }
        
        // enable tableView scroll when header fully collapsed
        self.tableViewDebat.isScrollEnabled = y > 130.0
    }
    
    private func collapseHeader() {
        // scroll top bottom will collapse the header
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    private func expandHeader() {
        // scroll to top will expand the header
        let bottomOffset = CGPoint(x: 0, y: -44)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}

extension LiveDebatController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    // TODO: replace with real data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell() as ArgumentLeftCell
            cell.lbArgument.text = "apaaaaa ?"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell() as ArgumentRightCell
            
            return cell
        }
    }
    
    
}
