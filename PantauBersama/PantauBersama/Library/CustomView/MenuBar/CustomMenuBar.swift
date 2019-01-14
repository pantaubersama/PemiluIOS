//
//  CustomMenuBar.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 13/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct MenuItem {
    let title: String
}

@IBDesignable
class CustomMenuBar: UIView {
    @IBOutlet weak var collectionViewMenu: UICollectionView!
    var menuItem: [MenuItem] = [] {
        didSet {
            setup()
        }
    }
    
    var selectedItemIndex: Int = 0 {
        didSet {
            selectedItem.accept(selectedItemIndex)
        }
    }
    
    private let selectedItem = BehaviorRelay<Int>(value: 0)
    var selectedIndex: Driver<Int>!
    private let disposeBag = DisposeBag()
    
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
        collectionViewMenu.dataSource = self
        collectionViewMenu.delegate = self
        collectionViewMenu.register(CustomMenuCell.nib, forCellWithReuseIdentifier: CustomMenuCell.identifier)
        
        selectedItem.asDriver()
            .drive(onNext: { [unowned self](index) in
                if !self.menuItem.isEmpty {
                    let selectedIndexPath = IndexPath(item: index, section: 0)
                    self.collectionViewMenu.selectItem(at: selectedIndexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                }
            })
            .disposed(by: disposeBag)
        selectedIndex = selectedItem.asDriver()
    }
}

extension CustomMenuBar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomMenuCell.identifier, for: indexPath) as! CustomMenuCell
        cell.configureItem(item: menuItem[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}

extension CustomMenuBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem.accept(indexPath.row)
        if indexPath.row < (menuItem.count - 1) {
            collectionView.scrollToItem(at: IndexPath(row: indexPath.row + 1, section: 0), at: .right, animated: true)
        }
    }
}
