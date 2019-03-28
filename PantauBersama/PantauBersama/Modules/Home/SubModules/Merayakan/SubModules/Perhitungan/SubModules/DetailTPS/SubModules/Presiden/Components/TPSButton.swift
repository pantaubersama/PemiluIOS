//
//  TPSButton.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 02/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class TPSButton: UIControl {
    private let bag = DisposeBag()
    
    @IBInspectable var plusButtonType: String = "green" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var fontSize: CGFloat = 12 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var suara: Int = 0 {
        didSet {
            textField.text = "\(suara)"
            sendActions(for: [.valueChanged, .editingChanged])
        }
    }
    
    var rx_suara: ControlProperty<Int> {
        return TPSButton.valuePublic(control: self, getter: { (control) -> Int in
            return control.suara
        }, setter: { (control, value) in
            control.suara = value
        })
    }
    
    lazy fileprivate var textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.layer.borderColor = Color.grey_three.cgColor
        tf.layer.borderWidth = 1
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textAlignment = .center
        tf.delegate = self
        tf.keyboardType = .numberPad
        return tf
    }()
    
    lazy fileprivate var plusButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textField.font = UIFont(name: "Lato-Regular", size: fontSize)
        
        if plusButtonType == "green" {
            textField.textColor = Color.secondary_cyan
            plusButton.setImage(UIImage(named: "icPlusGreen"), for: .normal)
        } else {
            textField.textColor = Color.primary_red
            plusButton.setImage(UIImage(named: "icPlusRed"), for: .normal)
        }
    }
    
    fileprivate func commonInit() {
        addSubview(textField)
        addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.widthAnchor.constraint(equalTo: self.heightAnchor),
            plusButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            plusButton.topAnchor.constraint(equalTo: self.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.topAnchor.constraint(equalTo: self.topAnchor),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: plusButton.centerXAnchor)])
        
        textField.rx
            .text
            .map({ Int($0 ?? "") ?? 0 })
            .bind(to: rx_suara )
            .disposed(by: bag)
        
    }
    
    @objc
    fileprivate func addPressed() {
        suara = suara + 1
    }
}

extension TPSButton: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        return true
    }
}

extension UIControl {
    static func valuePublic<T, ControlType: UIControl>(_ control: ControlType, getter:  @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> ()) -> ControlProperty<T> {
        let values: Observable<T> = Observable.deferred { [weak control] in
            guard let existingSelf = control else {
                return Observable.empty()
            }
            
            return (existingSelf as UIControl).rx.controlEvent([.allEditingEvents, .valueChanged])
                .flatMap { _ in
                    return control.map { Observable.just(getter($0)) } ?? Observable.empty()
                }
                .startWith(getter(existingSelf))
        }
        return ControlProperty(values: values, valueSink: Binder(control) { control, value in
            setter(control, value)
        })
    }
}
