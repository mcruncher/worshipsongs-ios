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
    private let preferences = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool{
        let version = getVersion()
        if preferences.dictionaryRepresentation().keys.contains("version") {
            if !(preferences.stringForKey("version")?.equalsIgnoreCase(version))! {
                copyFile("songs.sqlite")
            } else {
                print("Same version")
            }
            
        } else {
            preferences.setValue(version, forKey: "version")
            copyFile("songs.sqlite")
        }
        return true
    }
    
    func copyFile(fileName: NSString) {
        print("File copy started")
        let dbPath: String = commonService.getDocumentDirectoryPath(fileName as String)
        do {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(dbPath) {
                try fileManager.removeItemAtPath(dbPath)
            }
            let fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(fileName as String)
            try fileManager.copyItemAtPath(fromPath!, toPath: dbPath)
            print("File copied successfully in \(dbPath)")
        } catch let error as NSError {
            print("Error occurred while copy \(dbPath): \(error)")
        }
        
    }
    
    func getVersion() -> String {
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        return version! + "." + buildNumber!
    }
}

