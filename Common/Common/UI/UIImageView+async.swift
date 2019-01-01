//
//  UIImageView+async.swift
//  Common
//
//  Created by Rahardyan Bisma on 28/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    public func show(fromURL stringUrl: String) {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let imageFileName = stringUrl.components(separatedBy: "/").last!
        let imageURL = docDir.appendingPathComponent(imageFileName)
        //1. check if there is cached image data for stringUrl available
        UIImageView.imageCache.name = "imageCache"
        
        if let cachedImage = UIImageView.imageCache.object(forKey: stringUrl as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
        } else if let imageFromDir = UIImage(contentsOfFile: imageURL.path) {
            DispatchQueue.main.async {
                self.image = imageFromDir
            }
        }
        
        //2. update image data by downloading from the url
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: stringUrl) else {
                print("invalid image url")
                return
            }
            
            guard let imageData = try? Data(contentsOf: url) else {
                print("invalid image data")
                return
            }
            
            //3. save update image data to CacheManager
            let image = UIImage(data: imageData)
            UIImageView.imageCache.setObject(image as AnyObject, forKey: stringUrl as AnyObject)
            try! imageData.write(to: imageURL)
            
            //4. display image data
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
