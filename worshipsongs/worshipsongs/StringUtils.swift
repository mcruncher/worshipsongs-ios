//
//  StringUtils.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        
        get {
            
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (self as NSString).deletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).deletingPathExtension
        }
    }
    var pathComponents: [String] {
        
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathExtension(ext)
    }
    
    func equalsIgnoreCase(_ string: String) -> Bool {
        return self.caseInsensitiveCompare(string) == ComparisonResult.orderedSame
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    var toNSDate: Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let date = dateStringFormatter.date(from: self)!
        return date
    }
}
