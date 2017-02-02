//
//  ColorUtils.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 02/12/2016.
//  Copyright © 2016 Vignesh Palanisamy. All rights reserved.
//

import Foundation
import UIKit

struct ColorUtils {
   
    enum Color: String {
        case black, darkGray, lightGray, white, gray, red, green, blue, cyan, yellow, magenta, orange, purple, brown
        static let allValues = [black, darkGray, lightGray, white, gray, red, green, blue, cyan, yellow, magenta, orange, purple, brown]
    }
    
    static func getColor(color: Color) -> UIColor {
        switch color {
        case .black:
            return UIColor.black
        case .darkGray:
            return UIColor.darkGray
        case .lightGray:
            return UIColor.lightGray
        case .white:
            return UIColor.white
        case .gray:
            return UIColor.gray
        case .red:
            return UIColor.red
        case .green:
            return UIColor.green
        case .blue:
            return UIColor.blue
        case .cyan:
            return UIColor.cyan
        case .yellow:
            return UIColor.yellow
        case .magenta:
            return UIColor.magenta
        case .orange:
            return UIColor.orange
        case .purple:
            return UIColor.purple
        case .brown:
            return UIColor.brown
        }
    }
}

extension UIColor {
    
    class func cruncherBlue() -> UIColor {
        return UIColor(red: 61/255, green: 181/255, blue: 255/255, alpha: 1.0)
    }
}

