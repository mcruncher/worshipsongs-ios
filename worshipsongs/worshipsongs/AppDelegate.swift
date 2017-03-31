//
//  AppDelegate.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var progressView: UIView!
    let commonService = CommonService()
    let dataBaseService = DatabaseService()
    fileprivate let preferences = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        UINavigationBar.appearance().tintColor = UIColor.gray
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        let version = getVersion()
        if preferences.dictionaryRepresentation().keys.contains("version") {
            if !(preferences.string(forKey: "version")?.equalsIgnoreCase(version))! {
                dataBaseService.copyBundledDatabase("songs.sqlite")
                preferences.setValue(version, forKey: "version")
                preferences.synchronize()
            } else {
                print("Same version")
            }
            
        } else {
            preferences.setValue(version, forKey: "version")
            preferences.synchronize()
            dataBaseService.copyBundledDatabase("songs.sqlite")
        }
        updateDefaultSettings()
        createScheduleLocalNotification()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print(error)  
        }
        let presentationData = PresentationData()
        presentationData.registerForScreenNotification()
        setSplitViewController()
        return true
    }
    
    func setSplitViewController() {
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! SongsTabBarViewController
        
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! SongWithVideoViewController
        
        masterViewController.songdelegate = detailViewController
        
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }
    
    func updateDefaultSettings() {
        self.preferences.setValue("", forKey: "import.status")
        self.preferences.setValue("", forKey: "presentationSongName")
        self.preferences.setValue("", forKey: "presentationLyrics")
        self.preferences.setValue("", forKey: "presentationSlide")
        self.preferences.setValue(0, forKey: "presentationSlideNumber")
        self.preferences.setValue("", forKey: "presentationAuthor")
        self.preferences.synchronize()
    
        if !preferences.dictionaryRepresentation().keys.contains("database.lock") {
            self.preferences.set(false, forKey: "database.lock")
            self.preferences.synchronize()
        } else {
            if preferences.bool(forKey: "database.lock") {
                let databaseService = DatabaseService()
                databaseService.revertImport()
                preferences.set(false, forKey: "database.lock")
                preferences.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "onAfterUpdateDatabase"), object: nil,  userInfo: nil)
            }
        }
        if !preferences.dictionaryRepresentation().keys.contains("remote.url") {
            self.preferences.setValue("https://github.com/mcruncher/worshipsongs-db-dev/raw/master/songs.sqlite", forKey: "remote.url")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("defaultDatabase") {
            self.preferences.set(true, forKey: "defaultDatabase")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("latestFavoriteUpdated") {
            self.preferences.set(false, forKey: "latestFavoriteUpdated")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("fontSize") {
            self.preferences.setValue(17, forKey: "fontSize")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("presentationFontSize") {
            self.preferences.setValue(40, forKey: "presentationFontSize")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("tamilFontColor") {
            self.preferences.setValue(ColorUtils.Color.red.rawValue, forKey: "tamilFontColor")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("englishFontColor") {
            self.preferences.setValue(ColorUtils.Color.darkGray.rawValue, forKey: "englishFontColor")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("presentationTamilFontColor") {
            self.preferences.setValue(ColorUtils.Color.red.rawValue, forKey: "presentationTamilFontColor")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("presentationEnglishFontColor") {
            self.preferences.setValue(ColorUtils.Color.white.rawValue, forKey: "presentationEnglishFontColor")
            self.preferences.synchronize()
        }
        if !preferences.dictionaryRepresentation().keys.contains("presentationBackgroundColor") {
            self.preferences.setValue(ColorUtils.Color.black.rawValue, forKey: "presentationBackgroundColor")
            self.preferences.synchronize()
        }
        if self.preferences.array(forKey: "favorite") != nil {
            let favSongs  = self.preferences.array(forKey: "favorite") as! [String]
            var favoritesSongsWithOrders = [FavoritesSongsWithOrder]()
            for i in 0..<favSongs.count {
                favoritesSongsWithOrders.append(FavoritesSongsWithOrder(orderNo: i, songName: favSongs[i], songListName: "favorite"))
            }
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favoritesSongsWithOrders)
            self.preferences.set(encodedData, forKey: "favorite")
            self.preferences.set(true, forKey: "latestFavoriteUpdated")
            self.preferences.synchronize()
        }
        if !self.preferences.bool(forKey: "latestFavoriteUpdated") {
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: [FavoritesSongsWithOrder]())
            self.preferences.set(encodedData, forKey: "favorite")
            self.preferences.set(true, forKey: "latestFavoriteUpdated")
            self.preferences.synchronize()
        }
    }
    
    func getVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return version! + "." + buildNumber!
    }
    
    func createScheduleLocalNotification() {
        print("Preparing to create schedule notification...")
        let notifications = UIApplication.shared.scheduledLocalNotifications
        if (notifications?.count)! < 1 {
            let uiLocalnotification = UILocalNotification()
            uiLocalnotification.fireDate = "2016-12-25".toNSDate
            uiLocalnotification.timeZone = TimeZone(abbreviation: "GMT")
            uiLocalnotification.alertBody = "message.christmas".localized
            uiLocalnotification.soundName = UILocalNotificationDefaultSoundName
            uiLocalnotification.userInfo = ["id": 2016]
            uiLocalnotification.repeatInterval = .year
            UIApplication.shared.scheduleLocalNotification(uiLocalnotification)
        }
    }
    
}

