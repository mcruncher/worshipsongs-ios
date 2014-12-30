//
//  CustomTagColorService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit



class CustomTextSettingService{
    
    var customTagTextRange: NSMutableArray = NSMutableArray()
    var customCellText: NSString = NSString()
    let startPattern = "\\{\\w\\}"
    let endPattern = "\\{/\\w\\}"
    
    func getAttributedString(cellText : NSString) -> NSMutableAttributedString {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        var array = getCustomTagRanges(cellText)
        
        if(array.count > 0)
        {
            findRanges(cellText, ranges: array)
        }
        else
        {
            customCellText = cellText
            customTagTextRange = array
        }
        
        
        let attributedString = NSMutableAttributedString(string: customCellText, attributes: getFont())
        attributedString.addAttribute(NSForegroundColorAttributeName, value: settingDataManager.getPrimaryFontColor, range: NSRange(location: 0, length: customCellText.length))
        for var index=0; index < customTagTextRange.count; index++ {
            var rangeValue:NSRange
            rangeValue = customTagTextRange.objectAtIndex(index).rangeValue
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
    
    
    func findRanges(cellText : NSString, ranges: NSMutableArray) {
        var startIndex: Int = 0
        
        for var index=1; index <= ranges.count; index++ {
            var rangeValue:NSRange
            rangeValue = ranges.objectAtIndex(index-1).rangeValue
        
            var totalPatternLength: Int = 0
            totalPatternLength = totalPatternLengthValue(cellText)
            if(rangeValue.location > 0){
               customTagTextRange.addObject(NSMakeRange(rangeValue.location - startIndex, rangeValue.length - 6))
               startIndex = startIndex + totalPatternLength
            }
            else{
                startIndex = startIndex + totalPatternLength
                customTagTextRange.removeAllObjects()
                customTagTextRange.addObject(NSMakeRange(rangeValue.location, (rangeValue.length - startIndex)))
            }
            customCellText = removePatternText(cellText, startPattern)
            customCellText = removePatternText(customCellText, endPattern)
        }
    }
    
    func totalPatternLengthValue(text: NSString) -> Int{
        let startPattern = "\\{\\w\\}"
        let endPattern = "\\{/\\w\\}"
        return getPatternTextLength(text, startPattern) + getPatternTextLength(text, endPattern)
    }
}