//
//  DetailJanjiController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class DetailJanjiController: UIViewController {
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var iconParpol: UIImageView!
    @IBOutlet weak var nameParpol: Label!
    @IBOutlet weak var jumlahAnggota: Label!
    @IBOutlet weak var contentSource: UITextView!
    
    @IBOutlet weak var contentConstraintHeight: UITextView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: Label!
    @IBOutlet weak var motoLabel: Label!
    @IBOutlet weak var dateLabel: Label!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private lazy var janjiAlert = CustomActionSheet<JanjiType>(controller: self, with: [.hapus, .salin, .bagikan, .laporkan])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        moreButton.rx.tap
            .flatMapLatest({ self.janjiAlert.value })
            .do(onNext: { [weak self] (source) in
                guard let `self` = self else { return }
                switch source {
                case .hapus:
                    print("HAPUS..KAMU")
                case .salin:
                    print("SALIN KAMU")
                case .bagikan:
                    print("KU TAK RELA")
                case .laporkan:
                    print("KU Laporkan U")
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        // MARK
        // Setup content source
        setupContentSource()
    }
    
    private func setupContentSource() {
        contentSource.textAlignment = .justified
    }
    
}
