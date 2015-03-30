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
        //Copy Database
        utilClass.copyFile("songs.sqlite")
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
