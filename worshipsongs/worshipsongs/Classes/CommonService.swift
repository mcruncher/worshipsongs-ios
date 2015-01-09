//
//  CommonService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/9/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation

import UIKit
import SystemConfiguration

class CommonService: NSObject {
    
    
    func getDocumentDirectoryPath(fileName: String) -> String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent(fileName)
    }
    
    func getVersionNumber() -> String{
        let text = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        return text!
    }
}