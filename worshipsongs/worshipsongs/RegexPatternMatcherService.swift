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
    
    func getRange (_ value : String, pattern : String) -> NSMutableArray {
        let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
        let options = NSRegularExpression.Options.anchorsMatchLines
        let re = try! NSRegularExpression(pattern: pattern, options: options)
        
        let all = NSRange(location: 0, length: nsstr.length)
        let moptions = NSRegularExpression.MatchingOptions(rawValue: 0)
        let array: NSMutableArray = NSMutableArray()
        re.enumerateMatches(in: value, options: moptions, range: all) { (result, flags, ptr) -> Void in
            nsstr.substring(with: result!.range)
            array.add(result!.range)
        }
        return array
    }
    
    func getPatternTextLength (_ value : String, pattern : String) -> Int {
        var length: Int = Int()
        let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
        let options = NSRegularExpression.Options(rawValue: 0)
        let re = try! NSRegularExpression(pattern: pattern, options: options)
        let all = NSRange(location: 0, length: nsstr.length)
        let moptions = NSRegularExpression.MatchingOptions(rawValue: 0)
        re.enumerateMatches(in: value, options: moptions, range: all) { (result, flags, ptr) -> Void in
            nsstr.substring(with: result!.range)
            length = result!.range.length
        }
        return length
    }
    
    
    func removePatternText(_ text: NSString, pattern: NSString) -> NSString
    {
        var internalExpression: NSRegularExpression
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        internalExpression = try! NSRegularExpression(pattern: pattern as String, options: .caseInsensitive)
        return internalExpression.stringByReplacingMatches(in: text as String, options: options, range: NSMakeRange(0, text.length), withTemplate: "") as NSString
    }
    
    func isPatternExists(_ text: NSString, pattern: NSString) -> Bool
    {
        var internalExpression: NSRegularExpression
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        internalExpression = try! NSRegularExpression(pattern: pattern as String, options: .caseInsensitive)
        return internalExpression.matches(in: text as String, options: options, range: NSMakeRange(0, text.length)).count > 0
    }
    
}
