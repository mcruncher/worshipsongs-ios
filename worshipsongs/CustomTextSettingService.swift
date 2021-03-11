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
    let regexPatternMatcherService: RegexPatternMatcherService = RegexPatternMatcherService()
    var customCellText: NSString = NSString()
    let startPattern = "\\{\\w\\}"
    let endPattern = "\\{/\\w\\}"
    fileprivate let preferences = UserDefaults.standard
    
    func getAttributedString(_ cellText : NSString) -> NSMutableAttributedString {
        return getAttributedString(cellText, secondScreen: false)
    }

    
    func getAttributedString(_ cellText : NSString, secondScreen: Bool) -> NSMutableAttributedString {
        let tagExists = regexPatternMatcherService.isPatternExists(cellText, pattern: startPattern as NSString)
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
        var englishFont = self.preferences.string(forKey: "englishFontColor")!
        if secondScreen {
            englishFont = self.preferences.string(forKey: "presentationEnglishFontColor")!
        }
        let displayRomanised = self.preferences.bool(forKey: "displayRomanised")
        let displayTamil = self.preferences.bool(forKey: "displayTamil")
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: ColorUtils.getColor(color: ColorUtils.Color(rawValue: englishFont)!), range: textRange)
        print("attributed String \(attributedString)")
        if tagExists {
            if !displayRomanised && displayTamil {
                return getOnlyTamilLyrics(attributedString: attributedString, secondScreen: secondScreen)
            } else if displayRomanised && !displayTamil {
                return getOnlyEnglishLyrics(attributedString: attributedString)
            }
        }
        return getAllLyrics(attributedString: attributedString, secondScreen: secondScreen)
        
    }
    
    func getOnlyTamilLyrics(attributedString: NSMutableAttributedString, secondScreen: Bool) -> NSMutableAttributedString {
        var tamilFont = self.preferences.string(forKey: "tamilFontColor")!
        if secondScreen {
            tamilFont = self.preferences.string(forKey: "presentationTamilFontColor")!
        }
        let onlyTamilAttribute: NSMutableAttributedString = NSMutableAttributedString(string: "")
        for index in 0 ..< customTagTextRange.count {
            let rangeValue: NSRange = (customTagTextRange.object(at: index) as AnyObject).rangeValue
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: ColorUtils.getColor(color: ColorUtils.Color(rawValue: tamilFont)!), range: rangeValue)
            onlyTamilAttribute.append(attributedString.attributedSubstring(from: rangeValue))
            if index != customTagTextRange.count - 1 {
                onlyTamilAttribute.append(NSAttributedString(string: "\n"))
            }
        }
        return onlyTamilAttribute
    }
    
    func getOnlyEnglishLyrics(attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        let onlyEnglishAttribute: NSMutableAttributedString = NSMutableAttributedString(string: "")
        var startPosition = 0
        var length = 0
        for index in 0 ..< customTagTextRange.count {
            let rangeValue: NSRange = (customTagTextRange.object(at: index) as AnyObject).rangeValue
            length = rangeValue.location - startPosition
            if length > 0 {
                onlyEnglishAttribute.append(attributedString.attributedSubstring(from: NSMakeRange(startPosition, length)))
            }
            startPosition = startPosition + length + rangeValue.length + 1
            if index == customTagTextRange.count - 1 && attributedString.length > startPosition {
                length = attributedString.length - startPosition
                onlyEnglishAttribute.append(attributedString.attributedSubstring(from: NSMakeRange(startPosition, length)))
            }
        }
        return onlyEnglishAttribute
    }
    
    func getAllLyrics(attributedString: NSMutableAttributedString, secondScreen: Bool) -> NSMutableAttributedString {
        var tamilFont = self.preferences.string(forKey: "tamilFontColor")!
        if secondScreen {
            tamilFont = self.preferences.string(forKey: "presentationTamilFontColor")!
        }
        for index in 0 ..< customTagTextRange.count {
            let rangeValue: NSRange = (customTagTextRange.object(at: index) as AnyObject).rangeValue
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: ColorUtils.getColor(color: ColorUtils.Color(rawValue: tamilFont)!), range: rangeValue)
        }
        return attributedString
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
