//
//  CustomActionSheet.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CustomActionSheet<E: RawRepresentable> {
    
    private let sources: [E]
    private let controller: UIViewController
    
    var value: Observable<E> {
        return selectedOption
    }
    
    private var selectedOption: Observable<E> {
        return Observable.create{ [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let actionSheet = self.prepareActionSheet(with: observer)
            self.controller.present(actionSheet, animated: true)
            
            return Disposables.create {
                actionSheet.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    init(controller: UIViewController, with sources: [E]) {
        self.sources = sources
        self.controller = controller
    }
    
    private func prepareActionSheet(with actionTapObserver: AnyObserver<E>) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        prepareActionSheetActions(with: actionTapObserver)
            .forEach { actionSheet.addAction($0) }
        return actionSheet
    }
    
    private func prepareActionSheetActions(with tapObserver: AnyObserver<E>) -> [UIAlertAction] {
        var actions = createSourcesActions(with: tapObserver)
        let cancel = createCancelAction(with: tapObserver)
        actions.append(cancel)
        return actions
    }
    
    private func createSourcesActions(with tapObserver: AnyObserver<E>) -> [UIAlertAction] {
        return sources.map { source in
            return UIAlertAction(
                title: (source as! CustomStringConvertible).description,
                style: .default,
                handler: { _ in
                    tapObserver.onNext(source)
                    tapObserver.onCompleted()
                }
            )}
        }
    
    private func createCancelAction(with tapObserver: AnyObserver<E>) -> UIAlertAction {
        return UIAlertAction(title: "Cancel",
                             style: .cancel,
                             handler: { _ in
                                tapObserver.onCompleted()
        })
    }
    
}
