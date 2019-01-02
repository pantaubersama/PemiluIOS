//
//  WebController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 02/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import Common

class WebController: UIViewController {
    
    private lazy var wkwebView: WKWebView = {
       let wk = WKWebView()
        return wk
    }()
    private var config = WKWebViewConfiguration()
    
    let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progressTintColor = Color.primary_red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewModel: WebViewModel!
    private let disposeBag = DisposeBag()
    
    deinit {
        wkwebView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func loadView() {
        wkwebView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(wkwebView.estimatedProgress)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        // MARK
        // Configure wkwebview
        view = wkwebView
        wkwebView.navigationDelegate = self
        // configure progressview
        [progressView].forEach { self.view.addSubview($0) }
        progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            progressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        viewModel.output.url
            .drive(onNext: { [weak self] (url) in
                guard let `self` = self else { return }
                self.wkwebView.load(URLRequest(url: URL(string: url)!))
            })
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.nextO
            .drive()
            .disposed(by: disposeBag)
     
    }
    
}

extension WebController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideProgressView()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideProgressView()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showProgressView()
    }
}

extension WebController {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = navigationAction.request.url?.getQueryString(parameter: "code") {
            viewModel.input.codeI.onNext(code)
        }
        
        decisionHandler(.allow)
    }
}


extension WebController {
    func showProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 1
        }, completion: nil)
    }
    
    func hideProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0
        }, completion: nil)
    }
}
