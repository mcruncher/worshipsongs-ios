//
//  AppDelegate.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/16/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var progressView: UIView!
    let utilClass:Util = Util()
    let connectionService:ConnectionService = ConnectionService()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool{
        var documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var databasePath = documentDirectoryPath.stringByAppendingPathComponent("songs.sqlite")
        var checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(databasePath)){
            println("database Already copied");
        }
        else{
             utilClass.copyFile("songs.sqlite")
        }
        let masterViewController = MasterViewController(style:UITableViewStyle.Grouped)
        let navController = UINavigationController(rootViewController: masterViewController)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navController.navigationBar.titleTextAttributes = titleDict
                
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
