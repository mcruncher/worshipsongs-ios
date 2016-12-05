//
//  CustomTextSettingService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 03/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit
import Foundation


class CustomTextSettingService {
    
    var customTagTextRange: NSMutableArray = NSMutableArray()
    let regexPatternMatcherService:RegexPatternMatcherService = RegexPatternMatcherService()
    var customCellText: NSString = NSString()
    let startPattern = "\\{\\w\\}"
    let endPattern = "\\{/\\w\\}"
    fileprivate let preferences = UserDefaults.standard

    
    func getAttributedString(_ cellText : NSString) -> NSMutableAttributedString {
        print("cell Text \(cellText)")
        let customTagRangeArray = getCustomTagRanges(cellText)
        if(customTagRangeArray.count > 0)
        {
            customTagTextRange = findCustomTagTextRange(cellText, customTagRangeArray: customTagRangeArray)
            customCellText = removePattern(cellText)
        }
        else
        {
            customCellText = cellText
            customTagTextRange = customTagRangeArray
        }
        let attributedString = NSMutableAttributedString(string: customCellText as String)
        let textRange = NSMakeRange(0, customCellText.length)
        let englishFont = self.preferences.string(forKey: "englishFontColor")!
        attributedString.addAttribute(NSForegroundColorAttributeName, value: ColorUtils.getColor(color: ColorUtils.Color(rawValue: englishFont)!), range: textRange)
        
        for index in 0 ..< customTagTextRange.count {
            var rangeValue:NSRange
            rangeValue = (customTagTextRange.object(at: index) as AnyObject).rangeValue
            let tamilFont = self.preferences.string(forKey: "tamilFontColor")!
            attributedString.addAttribute(NSForegroundColorAttributeName, value: ColorUtils.getColor(color: ColorUtils.Color(rawValue: tamilFont)!), range: rangeValue)
        }
        print("attributed String \(attributedString)")
        return attributedString;
    }
    
    func getCustomTagRanges(_ cellText : NSString) -> NSMutableArray{
        
        var startTagArray: NSMutableArray = NSMutableArray()
        var endTagArray: NSMutableArray = NSMutableArray()
        let tagRange: NSMutableArray = NSMutableArray()
        
        startTagArray = regexPatternMatcherService.getRange(cellText as String, pattern: startPattern)
        endTagArray = regexPatternMatcherService.getRange(cellText as String, pattern: endPattern)
        if(startTagArray.count == endTagArray.count){
            for index in 0 ..< startTagArray.count {
                var startRangeValue:NSRange
                var endRangeValue:NSRange
                var customRange:NSRange
                startRangeValue = (startTagArray.object(at: index) as AnyObject).rangeValue
                endRangeValue = (endTagArray.object(at: index) as AnyObject).rangeValue
                customRange = NSMakeRange(startRangeValue.location, (endRangeValue.location + endRangeValue.length) - startRangeValue.location)
                tagRange.add(customRange)
            }
        }
        return tagRange
    }
    
    func findCustomTagTextRange(_ cellText : NSString, customTagRangeArray: NSMutableArray) -> NSMutableArray{
        var startIndex: Int = 0
        let tagTextRange: NSMutableArray = NSMutableArray()
        for index in 0 ..< customTagRangeArray.count {
            var rangeValue:NSRange
            rangeValue = (customTagRangeArray.object(at: index) as AnyObject).rangeValue
            var totalPatternLength: Int = 0
            totalPatternLength = totalPatternLengthValue(cellText)
            
            if(rangeValue.location > 0){
                tagTextRange.add(NSMakeRange(rangeValue.location - startIndex, rangeValue.length - totalPatternLength))
                startIndex = startIndex + totalPatternLength
            }
            else{
                startIndex = startIndex + totalPatternLength
                tagTextRange.removeAllObjects()
                tagTextRange.add(NSMakeRange(rangeValue.location, (rangeValue.length - startIndex)))
            }
        }
        return tagTextRange
    }
    
    func removePattern(_ cellText : NSString) -> NSString{
        var patternRemovedText: NSString = NSString()
        patternRemovedText = regexPatternMatcherService.removePatternText(cellText, pattern: startPattern as NSString)
        patternRemovedText = regexPatternMatcherService.removePatternText(patternRemovedText, pattern: endPattern as NSString)
        return patternRemovedText
    }
    
    
    func getCustomTagRangesByRegex(_ cellText : NSString) -> NSMutableArray{
        let customTagRegexPattern = "\\{\\w\\}.*\\{/\\w\\}"
        var array: NSMutableArray = NSMutableArray()
        array = regexPatternMatcherService.getRange(cellText as String,pattern: customTagRegexPattern)
        return array
    }
    
    func totalPatternLengthValue(_ text: NSString) -> Int{
        let startPattern = "\\{\\w\\}"
        let endPattern = "\\{/\\w\\}"
        return regexPatternMatcherService.getPatternTextLength(text as String, pattern: startPattern) + regexPatternMatcherService.getPatternTextLength(text as String, pattern: endPattern)
    }
}
