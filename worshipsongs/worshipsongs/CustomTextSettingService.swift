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
    
    func getAttributedString(cellText : NSString) -> NSMutableAttributedString {
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
        for index in 0 ..< customTagTextRange.count {
            var rangeValue:NSRange
            rangeValue = customTagTextRange.objectAtIndex(index).rangeValue
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: rangeValue)
        }
        print("attributed String \(attributedString)")
        return attributedString;
    }
    
    func getCustomTagRanges(cellText : NSString) -> NSMutableArray{
        
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
                startRangeValue = startTagArray.objectAtIndex(index).rangeValue
                endRangeValue = endTagArray.objectAtIndex(index).rangeValue
                customRange = NSMakeRange(startRangeValue.location, (endRangeValue.location + endRangeValue.length) - startRangeValue.location)
                tagRange.addObject(customRange)
            }
        }
        return tagRange
    }
    
    func findCustomTagTextRange(cellText : NSString, customTagRangeArray: NSMutableArray) -> NSMutableArray{
        var startIndex: Int = 0
        let tagTextRange: NSMutableArray = NSMutableArray()
        for index in 0 ..< customTagRangeArray.count {
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
        patternRemovedText = regexPatternMatcherService.removePatternText(cellText, pattern: startPattern)
        patternRemovedText = regexPatternMatcherService.removePatternText(patternRemovedText, pattern: endPattern)
        return patternRemovedText
    }
    
    
    func getCustomTagRangesByRegex(cellText : NSString) -> NSMutableArray{
        let customTagRegexPattern = "\\{\\w\\}.*\\{/\\w\\}"
        var array: NSMutableArray = NSMutableArray()
        array = regexPatternMatcherService.getRange(cellText as String,pattern: customTagRegexPattern)
        return array
    }
    
    func totalPatternLengthValue(text: NSString) -> Int{
        let startPattern = "\\{\\w\\}"
        let endPattern = "\\{/\\w\\}"
        return regexPatternMatcherService.getPatternTextLength(text as String, pattern: startPattern) + regexPatternMatcherService.getPatternTextLength(text as String, pattern: endPattern)
    }
}