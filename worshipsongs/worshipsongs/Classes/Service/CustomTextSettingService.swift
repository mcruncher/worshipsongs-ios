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
    
    
    func getCustomTagRangesByRegex(cellText : NSString) -> NSMutableArray{
        let customTagRegexPattern = "\\{\\w\\}.*\\{/\\w\\}"
        var array: NSMutableArray = NSMutableArray()
        array = getRange(cellText,customTagRegexPattern)
        return array
    }
    
    
    func getCustomTagRanges(cellText : NSString) -> NSMutableArray{
        
        var startTagArray: NSMutableArray = NSMutableArray()
        var endTagArray: NSMutableArray = NSMutableArray()
        var customTagRangeArray: NSMutableArray = NSMutableArray()
       
        startTagArray = getRange(cellText,startPattern)
        endTagArray = getRange(cellText,endPattern)
        if(startTagArray.count == endTagArray.count){
            for var index=0; index < startTagArray.count; index++ {
                var startRangeValue:NSRange
                var endRangeValue:NSRange
                var customRange:NSRange
                startRangeValue = startTagArray.objectAtIndex(index).rangeValue
                endRangeValue = endTagArray.objectAtIndex(index).rangeValue
                customRange = NSMakeRange(startRangeValue.location, (endRangeValue.location + endRangeValue.length) - startRangeValue.location)
                customTagRangeArray.addObject(customRange)
            }
        }
        return customTagRangeArray
    }
    
    
    func findRanges(cellText : NSString, ranges: NSMutableArray) {
        var startIndex: Int = 0
        
        for var index=0; index < ranges.count; index++ {
            var rangeValue:NSRange
            rangeValue = ranges.objectAtIndex(index).rangeValue
        
            var totalPatternLength: Int = 0
            totalPatternLength = totalPatternLengthValue(cellText)
           
            if(rangeValue.location > 0){
               customTagTextRange.addObject(NSMakeRange(rangeValue.location - startIndex, rangeValue.length - totalPatternLength))
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
    
    func getDefaultFont() -> UIFont{
        return UIFont(name: "HelveticaNeue", size: CGFloat(14))!
    }
    
    func getDefaultTextAttributes() -> NSDictionary{
        let textFontAttributes = [
            NSFontAttributeName: getDefaultFont(),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        return textFontAttributes
    }
}