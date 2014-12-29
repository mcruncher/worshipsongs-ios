//
//  CustomTagColorService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit



class CustomTextSettingService{
    
    func getAttributedString(cellText : NSString) -> NSMutableAttributedString {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        
        var array = getCustomTagRanges(cellText)
        let attributedString = NSMutableAttributedString(string: cellText, attributes: getFont())
        attributedString.addAttribute(NSForegroundColorAttributeName, value: settingDataManager.getPrimaryFontColor, range: NSRange(location: 0, length: cellText.length))
        for var index=0; index < array.count; index++ {
            var rangeValue:NSRange
            rangeValue = array.objectAtIndex(index).rangeValue
            let userSelectedPrimaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("secondaryFontColor") as? NSData
            var colorValue: UIColor = UIColor()
            colorValue = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedPrimaryColorData!) as UIColor
            attributedString.addAttribute(NSForegroundColorAttributeName, value: settingDataManager.getSecondaryFontColor, range: rangeValue)
        }
        
        return attributedString;
    }
    
    func getFont() -> NSDictionary {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        let fontName = settingDataManager.getFontName
        let font = UIFont(name: settingDataManager.getFontName, size: settingDataManager.getFontSize) ?? UIFont.systemFontOfSize(18.0)
        let textFont = [NSFontAttributeName:font]
        return textFont
    }
    
    
    func getCustomTagRanges(cellText : NSString) -> NSMutableArray{
        let startPattern = "\\{\\w\\}.*\\{/\\w\\}"
        let colorAttributedString = NSMutableAttributedString()
        var array: NSMutableArray = NSMutableArray()
        array = getRange(cellText,startPattern)
        return array
    }
}