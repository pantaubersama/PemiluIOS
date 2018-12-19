//
//  UIControl.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
// Thanks to alfian0

import RxSwift
import RxCocoa
import Common

extension UIControl {
    static func valuePublic<T, ControlType: UIControl>(control: ControlType, getter:  @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> ()) -> ControlProperty<T> {
        let values: Observable<T> = Observable.deferred { [weak control] in
            guard let `self` = control else {
                return Observable.empty()
            }
            
            return self.rx.controlEvent([.allEditingEvents, .valueChanged])
                .flatMapLatest { _ in
                    return control.map { Observable.just(getter($0)) } ?? Observable.empty()
                }
                .startWith(getter(self))
        }
        return ControlProperty(values: values, valueSink: Binder(control) { control, value in
            setter(control, value)
        })
    }
}

extension Reactive where Base: SegementedControl {
    public var value: ControlProperty<Int> {
        return UIControl.valuePublic(control: base, getter: { (control) in
            return control.selectedSegmentIndex
        }, setter: { (control, value) in
            control.selectedSegmentIndex = value
        })
    }
}

