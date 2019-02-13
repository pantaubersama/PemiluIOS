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
    @IBOutlet weak var btnScroll: Button!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewDebat: UITableView!
    @IBOutlet weak var tvInputDebat: UITextView!
    @IBOutlet weak var imageVs: UIImageView!
    @IBOutlet weak var constraintInputViewBottom: NSLayoutConstraint!
    
    private lazy var titleView = Button()
    private var isKeyboardAppear = false
    
    var viewModel: LiveDebatViewModel!
    
    private lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config input behavior
        configureInputView()
        
        // config button scroll behavior
        configureScrollButton()
        
        // for dummy ui
        tableViewDebat.dataSource = self
        tableViewDebat.tableFooterView = UIView()
        tableViewDebat.isScrollEnabled = false
        
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
        
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForKeyboardEvent()
        configureNavbar()
        configureTitleView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeForKeyboardEvent()
    }
    
    private func subscribeForKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeForKeyboardEvent() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        isKeyboardAppear = true
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // move input view above the keyboard and collapse the header
        UIView.animate(withDuration: 0.4) { [unowned self] in
            self.constraintInputViewBottom.constant += keyboardFrame.height
            self.view.layoutIfNeeded()
        }
        collapseHeader()
    }
    
    @objc func keyboardWillDisappear() {
        isKeyboardAppear = false
        // bring input view down
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.constraintInputViewBottom.constant = 0
            self.view.layoutIfNeeded()
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
                    self.tableViewDebat.scrollToRow(at: IndexPath(row: 19, section: 0), at: .bottom, animated: true)
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
        tvInputDebat.delegate = self
    }
    
    private func configureNavbar() {
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = back
        
        let more = UIBarButtonItem(image: #imageLiteral(resourceName: "icMoreVerticalWhite"), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = more
        
        self.navigationController?.navigationBar.configure(with: .transparent)
        
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
        titleView.setTitle("LIVE NOW", for: .normal)
        titleView.setImage(#imageLiteral(resourceName: "outlineLiveRed24Px"), for: .normal)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "hahahahahahaha"
        
        return cell
    }
    
    
}

extension LiveDebatController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // lightGray color indicate that the contents is a placeholder, then we need to make it nil
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = Color.primary_black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // if user stop editing and the text is empty, then we set the placeholder
        if textView.text.isEmpty {
            textView.text = "Tulis argumen kamu disini"
            textView.textColor = .lightGray
        }
    }
}
