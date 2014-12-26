//
//  CustomTagColorService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit



class CustomTextSettingService: NSObject{
    
    
        
    class func getAttributedString(cellText : NSString) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
       // attributedString.appendAttributedString(getMatchedStrings(cellText))
        let fontAttributedString = NSAttributedString(string: cellText, attributes:getFont())
        attributedString.appendAttributedString(fontAttributedString)
        return attributedString;
    }
    
    class func getFont() -> NSDictionary {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        let fontName = settingDataManager.getFontName
        let font = UIFont(name: settingDataManager.getFontName, size: settingDataManager.getFontSize) ?? UIFont.systemFontOfSize(18.0)
        let textFont = [NSFontAttributeName:font]
        return textFont
    }
    
    
//    class func applyTagColor(cellText : NSString) -> NSMutableAttributedString{
//        return ""
//    }
    
    class func getMatchedStrings(cellText : NSString) -> NSMutableAttributedString{
       
        let startPattern = "\\{\\w\\}.*\\{/\\w\\}"
        let colorAttributedString = NSMutableAttributedString()
//        for m in cellText {
//            if m as String != null
//            {
//                println("start matched pattern: \(m)")
//                var attrString: NSMutableAttributedString = NSMutableAttributedString(string: m as String,attributes : [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
//                attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(0, attrString.length))
//                colorAttributedString.appendAttributedString(attrString)
//            }
//            else {
//                println("start matched pattern: \(m)")
//                var attrString: NSMutableAttributedString = NSMutableAttributedString(string: m as String,attributes : [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
//                attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSMakeRange(0, attrString.length))
//                colorAttributedString.appendAttributedString(attrString)
//            }
//            
//        }
        
        
        for m in cellText =~ startPattern {
            println("start matched pattern: \(m)")
//            var attrString: NSMutableAttributedString = NSMutableAttributedString(string: m as String,attributes : [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
//            attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(0, attrString.length))
//            colorAttributedString.appendAttributedString(attrString)
        }
        
        return colorAttributedString
        
        
        
    }
    
    
    
}