//
//  RegexPatternMatcherService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 03/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import Foundation
import UIKit

class RegexPatternMatcherService{
    
    func getRange (value : String, pattern : String) -> NSMutableArray {
        let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
        let options = NSRegularExpressionOptions.AnchorsMatchLines
        let re = try! NSRegularExpression(pattern: pattern, options: options)
        
        let all = NSRange(location: 0, length: nsstr.length)
        let moptions = NSMatchingOptions(rawValue: 0)
        let array: NSMutableArray = NSMutableArray()
        re.enumerateMatchesInString(value, options: moptions, range: all) { (result, flags, ptr) -> Void in
            nsstr.substringWithRange(result!.range)
            array.addObject(result!.range)
        }
        return array
    }
    
    func getPatternTextLength (value : String, pattern : String) -> Int {
        var length: Int = Int()
        let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
        let options = NSRegularExpressionOptions(rawValue: 0)
        let re = try! NSRegularExpression(pattern: pattern, options: options)
        let all = NSRange(location: 0, length: nsstr.length)
        let moptions = NSMatchingOptions(rawValue: 0)
        re.enumerateMatchesInString(value, options: moptions, range: all) { (result, flags, ptr) -> Void in
            nsstr.substringWithRange(result!.range)
            length = result!.range.length
        }
        return length
    }
    
    
    func removePatternText(text: NSString, pattern: NSString) -> NSString
    {
        var internalExpression: NSRegularExpression
        let options = NSMatchingOptions(rawValue: 0)
        internalExpression = try! NSRegularExpression(pattern: pattern as String, options: .CaseInsensitive)
        return internalExpression.stringByReplacingMatchesInString(text as String, options: options, range: NSMakeRange(0, text.length), withTemplate: "")
    }
    
}
