//
//  ColorPaletteService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/31/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class ColorPaletteService{
    

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = cString.substringFromIndex(advance(cString.startIndex, 1))
    }
    
    if (countElements(cString) != 6) {
        //    return UIColor.grayColor()
    }
    
    var rgbValue:UInt32 = 0
    NSScanner(string: cString).scanHexInt(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func getColorPalette() -> Array<String>{
    var colorPalette: Array<String> = Array()
    let path = NSBundle.mainBundle().pathForResource("colorPalette", ofType: "plist")
    let pListArray = NSArray(contentsOfFile: path!)
    if let colorPalettePlistFile = pListArray {
        colorPalette = colorPalettePlistFile as [String]
    }
    return colorPalette
}

}