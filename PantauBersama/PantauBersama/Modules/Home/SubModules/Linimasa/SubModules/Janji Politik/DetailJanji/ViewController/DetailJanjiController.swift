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
import Networking

class DetailJanjiController: UIViewController {
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var iconParpol: UIImageView!
    @IBOutlet weak var nameParpol: Label!
    @IBOutlet weak var jumlahAnggota: Label!
    @IBOutlet weak var contentSource: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var contentConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: Label!
    @IBOutlet weak var motoLabel: Label!
    @IBOutlet weak var dateLabel: Label!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private lazy var janjiAlert = CustomActionSheet<JanjiType>(controller: self, with: [.hapus, .salin, .bagikan, .laporkan])
    var viewModel: DetailJanjiViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel.output.detailJanji
            .drive(onNext: { (data) in
                self.configure(data: data)
            })
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .bind(to: viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
        
        moreButton.rx.tap
            .bind(to: viewModel.input.moreTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (pilpres) -> Observable<JanjiType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.hapus)
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.salin)
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.bagikan)
                        observer.on(.completed)
                    })
                    let lapor = UIAlertAction(title: "Laporkan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.laporkan)
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    alert.addAction(hapus)
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(lapor)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelected
            .drive()
            .disposed(by: disposeBag)
        
        // MARK
        // Setup content source
        setupContentSource()
    }
    
    private func setupContentSource() {
        contentSource.textAlignment = .justified
        contentSource.isScrollEnabled = false
    }
    
    func configure(data: JanjiPolitik) {
        headerTitle.text = data.title
        contentSource.text = data.body
        image.af_setImage(withURL: URL(string: data.image.large.url)!)
        
        nameLabel.text = data.user.fullname
        motoLabel.text = ""
        dateLabel.text = data.createdAt
        
        let size = CGSize(width: contentSource.frame.width, height: .infinity)
        let estimateSize = contentSource.sizeThatFits(size)
        contentConstraintHeight.constant = estimateSize.height
        
        
    }
    
}

