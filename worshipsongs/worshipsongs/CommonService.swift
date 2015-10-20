//
//  CommonService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import Foundation

import UIKit
import SystemConfiguration

class CommonService: NSObject {
    
    
    func getDocumentDirectoryPath(fileName: String) -> String {
    
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0] 
        
        let databasePath = docsDir.stringByAppendingPathComponent(
            fileName)
        
//        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent(fileName)
//        print("Path : \(path)")
        return databasePath
    }
    
    func getVersionNumber() -> String{
        let text = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        return text!
    }
}
