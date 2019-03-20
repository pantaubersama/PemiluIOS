//
//  LinkPreviewView.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking
import RxSwift

@IBDesignable
class LinkPreviewView: UIView {
    
    @IBOutlet weak var btnCloseLink: UIButton!
    @IBOutlet weak var lblLink: Label!
    @IBOutlet weak var ivAvatarLink: CircularUIImageView!
    @IBOutlet weak var lblContent: Label!
    @IBOutlet weak var lblDescContent: Label!
    
    private(set) var disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let view = loadNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configureLink(url: String) {
        if url.isValidURL {
            NetworkService.instance.requestObject(OpiniumServiceAPI.crawl(url: url, refetch: true),
                                                  c: BaseResponse<CrawlResponse>.self)
                .subscribe(onSuccess: { [unowned self] (response) in
                    let data = response.data.url
                    self.lblLink.text = data.sourceUrl
                    self.lblContent.text = data.title
                    self.lblDescContent.text = data.bestDesc
                    if let best = data.bestImage {
                        self.ivAvatarLink.af_setImage(withURL: URL(string: best)!)
                    }
                    }, onError: { (e) in
                        print(e.localizedDescription)
                })
                .disposed(by: disposeBag)
        } else {
            print("link is invalid")
        }
    }
    
}


