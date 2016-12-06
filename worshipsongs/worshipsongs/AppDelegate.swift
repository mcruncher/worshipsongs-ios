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
    fileprivate let preferences = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        UINavigationBar.appearance().tintColor = UIColor.gray
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        let version = getVersion()
        if preferences.dictionaryRepresentation().keys.contains("version") {
            if !(preferences.string(forKey: "version")?.equalsIgnoreCase(version))! {
                copyFile("songs.sqlite")
            } else {
                print("Same version")
            }
            
        } else {
            preferences.setValue(version, forKey: "version")
            copyFile("songs.sqlite")
        }
        updateDefaultSettings()
        createScheduleLocalNotification()
        return true
    }
    
    func updateDefaultSettings() {
        if !preferences.dictionaryRepresentation().keys.contains("fontSize") {
            self.preferences.setValue(17, forKey: "fontSize")
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
    }
    
    func copyFile(_ fileName: NSString) {
        print("File copy started")
        let dbPath: String = commonService.getDocumentDirectoryPath(fileName as String)
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(atPath: dbPath)
            }
            let fromPath: String? = Bundle.main.resourcePath?.stringByAppendingPathComponent(fileName as String)
            try fileManager.copyItem(atPath: fromPath!, toPath: dbPath)
            print("File copied successfully in \(dbPath)")
        } catch let error as NSError {
            print("Error occurred while copy \(dbPath): \(error)")
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

