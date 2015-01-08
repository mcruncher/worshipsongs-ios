//
//  CustomTagColorService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit
import Foundation


class CustomTextSettingService {
    
    let settingDataManager:SettingsDataManager = SettingsDataManager()
    let textAttributeService:TextAttributeService = TextAttributeService()
    let regexMatcher: RegexMatcher = RegexMatcher()
    var customTagTextRange: NSMutableArray = NSMutableArray()
    var customCellText: NSString = NSString()
    let startPattern = "\\{\\w\\}"
    let endPattern = "\\{/\\w\\}"
    
    func getAttributedString(cellText : NSString) -> NSMutableAttributedString {
        var customTagRangeArray = getCustomTagRanges(cellText)
        if(customTagRangeArray.count > 0)
        {
            customTagTextRange = findRangesToApplyColor(cellText, customTagRangeArray: customTagRangeArray)
            customCellText = removePattern(cellText)
        }
        else
        {
            customCellText = cellText
            customTagTextRange = customTagRangeArray
        }
        let attributedString = NSMutableAttributedString(string: customCellText, attributes: textAttributeService.getUserDefaultFont())
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
    
    func getCustomTagRanges(cellText : NSString) -> NSMutableArray{
        
        var startTagArray: NSMutableArray = NSMutableArray()
        var endTagArray: NSMutableArray = NSMutableArray()
        var tagRange: NSMutableArray = NSMutableArray()
        
        startTagArray = regexMatcher.getRange(cellText,pattern: startPattern)
        endTagArray = regexMatcher.getRange(cellText,pattern: endPattern)
        if(startTagArray.count == endTagArray.count){
            for var index=0; index < startTagArray.count; index++ {
                var startRangeValue:NSRange
                var endRangeValue:NSRange
                var customRange:NSRange
                startRangeValue = startTagArray.objectAtIndex(index).rangeValue
                endRangeValue = endTagArray.objectAtIndex(index).rangeValue
                customRange = NSMakeRange(startRangeValue.location, (endRangeValue.location + endRangeValue.length) - startRangeValue.location)
                tagRange.addObject(customRange)
            }
        }
        return tagRange
    }
    
    func findRangesToApplyColor(cellText : NSString, customTagRangeArray: NSMutableArray) -> NSMutableArray{
        var startIndex: Int = 0
        var tagTextRange: NSMutableArray = NSMutableArray()
        for var index=0; index < customTagRangeArray.count; index++ {
            var rangeValue:NSRange
            rangeValue = customTagRangeArray.objectAtIndex(index).rangeValue
            var totalPatternLength: Int = 0
            totalPatternLength = totalPatternLengthValue(cellText)
            
            if(rangeValue.location > 0){
                tagTextRange.addObject(NSMakeRange(rangeValue.location - startIndex, rangeValue.length - totalPatternLength))
                startIndex = startIndex + totalPatternLength
            }
            else{
                startIndex = startIndex + totalPatternLength
                tagTextRange.removeAllObjects()
                tagTextRange.addObject(NSMakeRange(rangeValue.location, (rangeValue.length - startIndex)))
            }
        }
        return tagTextRange
    }
    
    func removePattern(cellText : NSString) -> NSString{
        var patternRemovedText: NSString = NSString()
        patternRemovedText = regexMatcher.removePatternText(cellText, pattern: startPattern)
        patternRemovedText = regexMatcher.removePatternText(patternRemovedText, pattern: endPattern)
        return patternRemovedText
    }
    
    func getCustomTagRangesByRegex(cellText : NSString) -> NSMutableArray{
        let customTagRegexPattern = "\\{\\w\\}.*\\{/\\w\\}"
        var array: NSMutableArray = NSMutableArray()
        array = regexMatcher.getRange(cellText,pattern: customTagRegexPattern)
        return array
    }
    
    func totalPatternLengthValue(text: NSString) -> Int{
        let startPattern = "\\{\\w\\}"
        let endPattern = "\\{/\\w\\}"
        return regexMatcher.getPatternTextLength(text, pattern: startPattern) + regexMatcher.getPatternTextLength(text, pattern: endPattern)
    }
}