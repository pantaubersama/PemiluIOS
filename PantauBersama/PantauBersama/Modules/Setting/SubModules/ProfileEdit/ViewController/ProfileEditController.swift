//
//  ProfileEditController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources
import Networking
import AlamofireImage

class ProfileEditController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateButton: Button!
    
    var viewModel: ProfileEditViewModel!
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfProfileInfoData>!
    
    private var headerEditProfile: HeaderEditProfile = {
       let view = HeaderEditProfile()
        return view
    }()
    
    var user: User! {
        didSet {
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK: TableView
        tableView.registerReusableCell(TextViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        viewModel.output.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        updateButton.rx.tap
            .bind(to: viewModel.input.doneI)
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfProfileInfoData>(configureCell: { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TextViewCell
            cell.configureCell(item: TextViewCell.Input(viewModel: self.viewModel, data: item))
            return cell
        })
        
        viewModel.output.items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.userData
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.headerEditProfile.configure(data: response)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.avatarSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.done
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppearI.onNext(())
        if let avatar = user.avatar.thumbnail.url {
            headerEditProfile.avatar.af_setImage(withURL: URL(string: avatar)!)
        }
    }
}

extension ProfileEditController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = dataSource.sectionModels[section].header
        switch data {
        case .editProfile:
            let view = headerEditProfile
                view.buttonGanti.rx.tap
                    .subscribe(onNext: { [weak self] (_) in
                        let controller = UIImagePickerController()
                        controller.sourceType = .photoLibrary
                        controller.delegate = self
                        self?.navigationController?.present(controller, animated: true, completion: nil)
                    })
                    .disposed(by: view.disposeBag)
            return view
        case .editDataLapor:
            let view = HeaderDataLapor()
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sectionModels[section].header.sizeHeader
    }
}

// MARK
// Image picker controller
extension ProfileEditController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         navigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else { return }
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.headerEditProfile.avatar.image = image
                self.viewModel.input.avatarI.onNext(image)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.headerEditProfile.avatar.image = image
                self.viewModel.input.avatarI.onNext(image)
            }
         })
    }
}
