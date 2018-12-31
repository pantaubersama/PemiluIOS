//
//  UIImage.swift
//  Common
//
//  Created by Hanif Sugiyanto on 31/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit


public extension UIImage {
    public static func image(from layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    // MARK
    // Use for gray scaling images
    public func ff_imageFilteredToGrayScale() -> UIImage? {
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: self)!
        
        // Set image color to b/w
        let bwFilter = CIFilter(name: "CIColorControls")!
        bwFilter.setValuesForKeys([kCIInputImageKey:ciImage, kCIInputBrightnessKey:NSNumber(value: 0.0), kCIInputContrastKey:NSNumber(value: 1.1), kCIInputSaturationKey:NSNumber(value: 0.0)])
        let bwFilterOutput = (bwFilter.outputImage)!
        
        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValuesForKeys([kCIInputImageKey:bwFilterOutput, kCIInputEVKey:NSNumber(value: 0.7)])
        let exposureFilterOutput = (exposureFilter.outputImage)!
        
        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: ciImage.extent)
        let resultImage = UIImage(cgImage: bwCGIImage!, scale: 1.0, orientation: self.imageOrientation)
        
        return resultImage
    }
}

public extension UIImageView {
    public func loadImage(using urlString: String) {
        let url = URL(string: urlString.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        image = nil
        let cache = NSCache<NSString, UIImage>()
        if let img = cache.object(forKey: urlString as NSString) {
            image = img
        } else {
            guard let `url` = url else { return }
            DispatchQueue.global().async {
                URLSession.shared.dataTask(with: url, completionHandler: { (d, _, e) in
                    if e == nil {
                        DispatchQueue.main.async(execute: {
                            if let `data` = d, let img = UIImage(data: data) {
                                cache.setObject(img, forKey: urlString as NSString)
                                self.image = img
                            }
                        })
                    }
                })
                    .resume()
            }
        }
    }
    // MARK
    // To change color what you want
    func changePngColorTo(color: UIColor){
        guard let image =  self.image else {return}
        self.image = image.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
