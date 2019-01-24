//
//  HTMLToString.swift
//  Common
//
//  Created by Hanif Sugiyanto on 24/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

public extension String{
    public var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    public var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


public extension String {
    
    public var utfData: Data {
        return Data(utf8)
    }
    
    public var attributedHtmlString: NSAttributedString? {
        
        do {
            return try NSAttributedString(data: utfData,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch {
            print("Error:", error)
            return nil
        }
    }
}


public extension UITextView {
    
    public func setAttributedHtmlText(_ html: String) {
        
        if let attributedText = html.attributedHtmlString {
            self.attributedText = attributedText
            self.font = UIFont(name: "Lato-Regular", size: 12)
        }
    }
}


public extension UILabel {
    public func setAttributedLabelHtmlText(_ html: String) {
        
        if let attributedText = html.attributedHtmlString {
            self.attributedText = attributedText
        }
    }
    
    func setHTML(html: String) {
        do {
            let attributedString: NSAttributedString = try NSAttributedString(data: html.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            self.attributedText = attributedString
            self.font = UIFont(name: "Lato-Regular", size: 12)
        } catch {
            self.text = html
        }
    }
}
