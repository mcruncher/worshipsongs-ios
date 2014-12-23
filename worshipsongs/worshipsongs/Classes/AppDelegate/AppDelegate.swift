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
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //let tableViewController = TableViewController(style: UITableViewStyle.Grouped)
        let masterViewController = MasterViewController(style:UITableViewStyle.Grouped)
        let navController = UINavigationController(rootViewController: masterViewController)
        navController.navigationBar.barTintColor = UIColor.grayColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navController.navigationBar.titleTextAttributes = titleDict
        Util.copyFile("songs.sqlite")
                
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
}
