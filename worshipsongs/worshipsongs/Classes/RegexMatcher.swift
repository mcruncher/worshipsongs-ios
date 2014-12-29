//
//  RegexMatcher.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation

func getRange (value : String, pattern : String) -> NSMutableArray {
    var err : NSError?
    let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
    let options = NSRegularExpressionOptions(0)
    let re = NSRegularExpression(pattern: pattern, options: options, error: &err)
    let all = NSRange(location: 0, length: nsstr.length)
    let moptions = NSMatchingOptions(0)
    var matches : Array<String> = []
    var array: NSMutableArray = NSMutableArray()
    re!.enumerateMatchesInString(value, options: moptions, range: all) {
        (result : NSTextCheckingResult!, flags : NSMatchingFlags, ptr : UnsafeMutablePointer<ObjCBool>) in
        let string = nsstr.substringWithRange(result.range)
        println("Range: \(result.range)")
        array.addObject(result.range)
    }
    return array
}


