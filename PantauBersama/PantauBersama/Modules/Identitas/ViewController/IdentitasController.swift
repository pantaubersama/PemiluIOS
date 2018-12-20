//
//  IdentitasController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import WebKit
import Common

class IdentitasController: UIViewController {
    
    private lazy var wkwebView = WKWebView()
    private let disposeBag = DisposeBag()
    
    var viewModel: IdentitasViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWKWebView()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.backOutput
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func setupWKWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "code")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        wkwebView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: config)
        self.view.addSubview(wkwebView)
        
        wkwebView.navigationDelegate = self
        
        let urlString = "\(AppContext.instance.infoForKey("DOMAIN_SYMBOLIC"))/oauth/authorize?client_id=\(AppContext.instance.infoForKey("CLIENT_ID"))&response_type=code&redirect_uri=\(AppContext.instance.infoForKey("REDIRECT_URI"))&scope="
        print(urlString)
        wkwebView.load(URLRequest(url: URL(string: urlString)!))
    }
}

extension IdentitasController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        print(body)
        if let dict = body as? Dictionary<String, AnyObject> {
            print(dict)
        }
    }
    
    
}

extension IdentitasController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if ((webView.url?.getQueryString(parameter: "code")) != nil) {
            print(navigationAction.request.url?.absoluteString)
            decisionHandler(.allow)
            // catch code
            
        } else {
            decisionHandler(.allow)
        }
    }
}

extension URL {
    func getQueryString(parameter: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == parameter }?
            .value
    }
}
