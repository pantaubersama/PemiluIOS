//
//  WKWebview.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 10/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Common
import RxSwift
import RxCocoa

class WKWebviewCustom: UIViewController, WKNavigationDelegate, WKUIDelegate {
   
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
    
    var activityIndicator: UIActivityIndicatorView!
    var url: String? = nil
    
    var viewModel: WKWebViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
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
        view = wkwebView
        wkwebView.navigationDelegate = self
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(handleBack(sender:)))
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // configure activity indicator
        configureActivity()
        // configure progressview
        configureProgressView()

        
        // TODO : some for reasons coming soon will disappear,
        // and we will need viewModel and coordinator
        if url != nil {
            wkwebView.load(URLRequest(url: URL(string: url ?? "")!))
        } else {
            viewModel.output.urlO
                .drive(onNext: { [weak self] (url) in
                    guard let `self` = self else { return }
                    self.wkwebView.load(URLRequest(url: URL(string: url)!))
                })
                .disposed(by: disposeBag)
        }
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideProgressView()
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.hideProgressView()
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         self.showProgressView()
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // MARK
        // TODO: For change password handler
            if navigationAction.request.url?.absoluteString == "\(AppContext.instance.infoForKey("DOMAIN_SYMBOLIC"))/" {
                decisionHandler(.cancel)
                let alert = UIAlertController(title: "Sukses", message: "Berhasil update sandi", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
                    self?.navigationController?.popViewController(animated: true)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                decisionHandler(.allow)
            }
        }
    
    @objc private func handleBack(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension WKWebviewCustom {
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
    
    func configureActivity() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        navigationItem.titleView = activityIndicator
    }
    
    func configureProgressView() {
        [progressView].forEach { self.view.addSubview($0) }
        progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            progressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
    }
}

