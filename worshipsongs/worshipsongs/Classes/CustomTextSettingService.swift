//
//  CustomTagColorService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit



class CustomTextSettingService: NSObject {
    
        
    class func getAttributedString(cellText : NSString) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        let fontAttributedString = NSAttributedString(string: cellText, attributes:getFont())
        attributedString.appendAttributedString(fontAttributedString)
        return attributedString;
    }
    
    class func getFont() -> NSDictionary {
        let font = UIFont(name: "Georgia", size: 12.0) ?? UIFont.systemFontOfSize(18.0)
        let textFont = [NSFontAttributeName:font]
        return textFont
    }
    
    
//    class func applyTagColor(cellText : NSString) -> NSMutableAttributedString{
//        return ""
//    }
    
//    class func getMatchedStrings(cellText : NSString){
//        let pattern = "[\\u6620-\\U0001F500]"
//        for m in cellText =~ pattern {
//            println("matched pattern: \(m)")
//        }
//    }
    
    
    
}