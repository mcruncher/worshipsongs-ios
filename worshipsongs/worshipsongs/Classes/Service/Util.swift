//
//  Util.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/19/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func getPath(fileName: String) -> String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent(fileName)
    }
    
    class func copyFile(fileName: NSString) {
        var dbPath: String = getPath(fileName)
        var fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            var fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(fileName)
            fileManager.copyItemAtPath(fromPath!, toPath: dbPath, error: nil)
        }
    }
    
    class func invokeAlertMethod(strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
        var alert: UIAlertView = UIAlertView()
        alert.message = strBody
        alert.title = strTitle
        alert.delegate = delegate
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    class func downloadFile()
    {
        println("Download Startted")
        var writeError: NSError?
        let filemanager = NSFileManager.defaultManager()
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let destinationPath:NSString = documentsPath.stringByAppendingString("/songs.sqlite")
        let url = "https://github.com/crunchersaspire/worshipsongs-db/blob/master/songs.sqlite?raw=true"
        let data = NSData(contentsOfFile: url, options: nil, error: nil)
        data?.writeToFile(destinationPath, options: NSDataWritingOptions.DataWritingAtomic, error: &writeError)
        if((writeError) != nil){
            NSLog("Error occured while downloading:", writeError!)
        }
    }
}
