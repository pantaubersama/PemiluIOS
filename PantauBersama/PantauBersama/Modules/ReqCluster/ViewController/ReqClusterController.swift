//
//  ReqClusterController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift
import Networking

class ReqClusterController: UIViewController {
    
    var viewModel: ReqClusterViewModel!
    @IBOutlet weak var iconCluster: UIImageView!
    @IBOutlet weak var buttonAddGambar: UIButton!
    @IBOutlet weak var tfNamaCluster: TextField!
    @IBOutlet weak var btnKategori: Button!
    @IBOutlet weak var tvDeskripsi: UITextView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var buttonDone: Button!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Request Buat Cluster"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnKategori.rx.tap
            .bind(to: viewModel.input.categoriesI)
            .disposed(by: disposeBag)
        
        tfNamaCluster.rx.text.orEmpty
            .bind(to: viewModel.input.clusterNameI)
            .disposed(by: disposeBag)
        
        tvDeskripsi.rx.text.orEmpty
            .bind(to: viewModel.input.clusterDescI)
            .disposed(by: disposeBag)
        
        buttonDone.rx.tap
            .asObservable()
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: "Apakah data yang kamu masukan sudah benar", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Tidak", style: .destructive, handler: nil)
                    let oke = UIAlertAction(title: "Ya", style: .default, handler: { (_) in
                        observer.onNext(())
                        observer.on(.completed)
                    })
                    alert.addAction(cancel)
                    alert.addAction(oke)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    
                    return Disposables.create()
                })
            }
            .bind(to: viewModel.input.createI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.categoriesO
            .map({ $0.name })
            .drive(onNext: { [weak self] (s) in
                guard let `self` = self else { return }
                self.btnKategori.setTitle(s, for: .normal)
            })
            .disposed(by: disposeBag)
        
        buttonAddGambar.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                let controller = UIImagePickerController()
                controller.sourceType = .photoLibrary
                controller.delegate = self
                self.navigationController?.present(controller, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.enableCreateO
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.buttonDone.backgroundColor = enable ? Color.primary_red : Color.grey_one
            })
            .drive(buttonDone.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.createO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(with: .white)
        
    }
    
}

extension ReqClusterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else { return }
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.avatar.image = image
                self.buttonAddGambar.setTitle("Ganti Gambar", for: .normal)
                self.viewModel.input.clusterAvatarI.onNext(image)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.avatar.image = image
                self.viewModel.input.clusterAvatarI.onNext(image)
                self.buttonAddGambar.setTitle("Ganti Gambar", for: .normal)
            }
        })
    }
}
