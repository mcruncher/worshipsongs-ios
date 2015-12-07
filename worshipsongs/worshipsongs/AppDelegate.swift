//
//  AppDelegate.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var progressView: UIView!
    let commonService = CommonService()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool{
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let databasePath = documentDirectoryPath.stringByAppendingPathComponent("songs.sqlite")
        let checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(databasePath)){
            print("database Already copied");
        }
        else{
            copyFile("songs.sqlite")
        }
        return true
    }
    
    func copyFile(fileName: NSString) {
        print("File copy started")
        let dbPath: String = commonService.getDocumentDirectoryPath(fileName as String)
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            let fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(fileName as String)
            do {
                try fileManager.copyItemAtPath(fromPath!, toPath: dbPath)
            } catch _ {
            }
        }
        print("File copied successfully in \(dbPath)")
    }
}

