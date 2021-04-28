//
//  Extensions.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 01/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import UIKit

/**
 Extensions of UIKit classes used in the app
*/

extension UIViewController {
    
    func isLandscapeScreenOrientation() -> Bool {
        //UIDevice.current.orientation.isLandscape { returns .unknown, bug in simulator?
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}

extension UIView {
    /**
     Finds parent view controller of the  view
    */
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as? UIViewController
            }
        }
        return nil
    }
    
    func animateLayer<Value>(_ keyPath: WritableKeyPath<CALayer, Value>, to value:Value, duration: CFTimeInterval) {
        let keyString = NSExpression(forKeyPath: keyPath).keyPath
        let animation = CABasicAnimation(keyPath: keyString)
        animation.fromValue = self.layer[keyPath: keyPath]
        animation.toValue = value
        animation.duration = duration
        self.layer.add(animation, forKey: animation.keyPath)
        var thelayer = layer
        thelayer[keyPath: keyPath] = value
    }

    /**
     Adds the shadow with given attributes to the view
    */
    func addShadow(withRadius radius: Float, withSize size: Float, withOpacity opacity: Float, withOffset offset: CGSize, withColor color: UIColor) {
        clipsToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = CGFloat(size)
        layer.cornerRadius = CGFloat(radius)
        layer.shadowOffset = offset
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(radius))
        layer.shadowPath = path.cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

extension Thread {
    
    var isRunningXCTest: Bool {
        for key in self.threadDictionary.allKeys {
            guard let keyAsString = key as? String else {
                continue
            }

            if keyAsString.split(separator: ".").contains("xctest") {
                return true
            }
        }
        return false
    }
}


extension String {
    
    func textToImage(_ fontSize: CGFloat) -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: fontSize) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}

extension UISlider {
    
    func setEmojiForIntensity(value percentage: Float) {
        switch percentage {
        case let x where x < 0.2:
            setThumbImage("😄".textToImage(20), for: .normal)
        case 0.2...0.4:
            setThumbImage("😅".textToImage(20), for: .normal)
        case 0.4...0.6:
            setThumbImage("😎".textToImage(20), for: .normal)
        case 0.6...0.8:
            setThumbImage("🥵".textToImage(20), for: .normal)
        case 0.8...1:
            setThumbImage("🤢".textToImage(20), for: .normal)
        default:
            print("Error: correct icon not found")
        }
    }
}
