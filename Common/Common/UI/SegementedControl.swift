//
//  SegmentedControl.swift
//  Common
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit

@IBDesignable
public class SegementedControl: UIControl {
    
    private var buttons = [UIButton]()
    private var selector: UIView!
    
    public var selectedSegmentIndex: Int = 0
    
    @IBInspectable
    public var titles: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    public var textColor: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    public var selectedColor: UIColor = UIColor.darkGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    public var selectedTextColor: UIColor = UIColor.darkGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    public var selectorHeight: CGFloat = 2.0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    public var font: UIFont = UIFont(name: "Lato-Bold", size: 16.0)! {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        buttons.removeAll()
        
        subviews.forEach { $0.removeFromSuperview() }
        
        buttons = titles.components(separatedBy: ",").map { (title) -> UIButton in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = font
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            return button
        }
        
        buttons[0].setTitleColor(selectedTextColor, for: .normal)
        
        let selectorWidth = self.frame.width / CGFloat(buttons.count)
        selector = UIView(frame: CGRect(x: 0, y: frame.height - selectorHeight, width: selectorWidth, height: selectorHeight))
        selector.backgroundColor = selectedColor
        addSubview(selector)
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(textColor, for: .normal)
            if button == sender {
                let position = frame.width / CGFloat(buttons.count) * CGFloat(index)
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = position
                })
                selectedSegmentIndex = index
                button.setTitleColor(selectedTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
}
