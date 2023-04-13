//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var progressView: UIView!
    var notificationCenterService: INotificationCenterService!
    let commonService = CommonService()
    let dataBaseService = DatabaseService()
    var preferencesService: IPreferencesService!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        notificationCenterService = NotificationCenterService()
        UINavigationBar.appearance().tintColor = UIColor.cruncherBlue()
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        let version = getVersion()
        if let appVersion = preferencesService.object(forKey: "version", local: true) as? String {
            if !(appVersion.equalsIgnoreCase(version)) {
                dataBaseService.copyBundledDatabase("songs.sqlite")
                preferencesService.set(version, forKey: "version", local: true)
            } else {
                print("Same version")
            }
            
        } else {
            print(version)
            preferencesService.set(version, forKey: "version", local: true)
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let url:NSURL = userActivity.webpageURL! as NSURL
        guard var importString = url.absoluteString?.lastPathComponent else {
            return true
        }
        if let i = importString.index(of: "?") {
            importString.remove(at: i)
        }
        guard let importFav = importString.fromBase64()?.split(separator: ";") else {
            return true
        }
        let favoriteName = String(importFav[0])
        var favSongs:[String] = [String]()
        let databaseHelper = DatabaseHelper()
        for j in 1..<importFav.count {
            let songs = databaseHelper.findSongs(bySongIds: [String(importFav[j])])
            if songs.count > 0 {
                favSongs.append(String(songs[0].title))
            }
        }
        var favoritesSongsWithOrders = [FavoritesSongsWithOrder]()
        for i in 0..<favSongs.count {
            favoritesSongsWithOrders.append(FavoritesSongsWithOrder(orderNo: i, songName: favSongs[i], songListName: favoriteName))
        }
        if var favoriteList = preferencesService.object(forKey: CommonConstansts.favorites, local: false) as? [String] {
            if !favoriteList.contains(favoriteName) {
                favoriteList.append(favoriteName)
                preferencesService.set(favoriteList, forKey: CommonConstansts.favorites, local: false)
            }
        }
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favoritesSongsWithOrders)
        preferencesService.set(encodedData, forKey: favoriteName, local:false)
        notificationCenterService.post(name: CommonConstansts.updateFavorites, userInfo: nil)
        notificationCenterService.post(name: CommonConstansts.activeTabbar, userInfo: [CommonConstansts.activeTab: "favorites".localized])
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
        preferencesService.set("", forKey: "import.status", local: true)
        preferencesService.set("", forKey: "update.status", local: true)
        preferencesService.set("", forKey: "presentationSongName", local: true)
        preferencesService.set("", forKey: "presentationLyrics", local: true)
        preferencesService.set("", forKey: "presentationSlide", local: true)
        preferencesService.set(0, forKey: "presentationSlideNumber", local: true)
        preferencesService.set("", forKey: "presentationAuthor", local: true)
        
        if !preferencesService.isExist(forKey: "displayRomanised", local: false) {
            if let displayRomanised = preferencesService.object(forKey: "displayRomanised", local: true) as? Bool {
                preferencesService.set(displayRomanised, forKey: "displayRomanised", local: false)
            } else {
                preferencesService.set(true, forKey: "displayRomanised", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "displayTamil", local: false) {
            if let displayTamil = preferencesService.object(forKey: "displayTamil", local: true) as? Bool {
                preferencesService.set(displayTamil, forKey: "displayTamil", local: false)
            } else {
                preferencesService.set(true, forKey: "displayTamil", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "sha", local: false) {
            if let sha = preferencesService.object(forKey: "sha", local: true) as? String {
                preferencesService.set(sha, forKey: "sha", local: false)
            } else {
                preferencesService.set("no_sha", forKey: "sha", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "searchBy", local: false) {
            if let searchBy = preferencesService.object(forKey: "searchBy", local: true) as? String {
                preferencesService.set(searchBy, forKey: "searchBy", local: false)
            } else {
                preferencesService.set("searchByTitle", forKey: "searchBy", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: CommonConstansts.searchKey, local: false) {
            if let searchKey = preferencesService.object(forKey: CommonConstansts.searchKey, local: true) as? String {
                preferencesService.set(searchKey, forKey: CommonConstansts.searchKey, local: false)
            } else {
                preferencesService.set(CommonConstansts.searchByTitleOrNumber, forKey: CommonConstansts.searchKey, local: false)

            }
        }
        
        if let databaseLock = preferencesService.object(forKey: "database.lock", local: true) as? Bool {
            if databaseLock {
                let databaseService = DatabaseService()
                databaseService.revertImport()
                preferencesService.set(false, forKey: "database.lock", local: true)
                notificationCenterService.post(name: "refreshTabbar", userInfo: nil)
            }
        } else {
            preferencesService.set(false, forKey: "database.lock", local: true)
        }
        
        if let updateLock = preferencesService.object(forKey: "update.lock", local: true) as? Bool {
            if updateLock {
                let databaseService = DatabaseService()
                databaseService.revertUpdate()
                preferencesService.set(false, forKey: "update.lock", local: true)
                notificationCenterService.post(name: "refreshTabbar", userInfo: nil)
            }
        } else {
            preferencesService.set(false, forKey: "update.lock", local: true)
        }
    
        if !preferencesService.isExist(forKey: "check.update.url", local: false) {
            if let checkUpdateUrl = preferencesService.object(forKey: "check.update.url", local: true) as? String {
                preferencesService.set(checkUpdateUrl, forKey: "check.update.url", local: false)
            } else {
                preferencesService.set("https://api.github.com/repos/mcruncher/worshipsongs-db-dev/git/refs/heads/master", forKey: "check.update.url", local: false)
            }
        }
        
        if !preferencesService.isExist(forKey: "update.url", local: false) {
            if let updateUrl = preferencesService.object(forKey: "update.url", local: true) as? String {
                preferencesService.set(updateUrl, forKey: "update.url", local: false)
            } else {
                preferencesService.set("https://github.com/mcruncher/worshipsongs-db-dev/raw/master/songs.sqlite", forKey: "update.url", local: false)
            }
        }
    
        if !preferencesService.isExist(forKey: "remote.url", local: false) {
            if let remoteUrl = preferencesService.object(forKey: "remote.url", local: true) as? String {
                preferencesService.set(remoteUrl, forKey: "remote.url", local: false)
            } else {
                preferencesService.set("https://github.com/mcruncher/worshipsongs-db-dev/raw/master/songs.sqlite", forKey: "remote.url", local: false)
            }
        }
        
        if !preferencesService.isExist(forKey: "defaultDatabase", local: false) {
            if let defaultDatabase = preferencesService.object(forKey: "defaultDatabase", local: true) as? Bool {
                preferencesService.set(defaultDatabase, forKey: "defaultDatabase", local: false)
            } else {
                preferencesService.set(true, forKey: "defaultDatabase", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "latestFavoriteUpdated", local: false) {
            if let latestFavoriteUpdated = preferencesService.object(forKey: "latestFavoriteUpdated", local: true) as? Bool {
                preferencesService.set(latestFavoriteUpdated, forKey: "latestFavoriteUpdated", local: false)
            } else {
                preferencesService.set(false, forKey: "latestFavoriteUpdated", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "fontSize", local: false) {
            if let fontSize = preferencesService.object(forKey: "fontSize", local: true) as? Int {
                preferencesService.set(fontSize, forKey: "fontSize", local: false)
            } else {
                preferencesService.set(17, forKey: "fontSize", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "presentationFontSize", local: false) {
            if let presentationFontSize = preferencesService.object(forKey: "presentationFontSize", local: true) as? Int {
                preferencesService.set(presentationFontSize, forKey: "presentationFontSize", local: false)
            } else {
                preferencesService.set(40, forKey: "presentationFontSize", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "tamilFontColor", local: false) {
            if let tamilFontColor = preferencesService.object(forKey: "tamilFontColor", local: true) as? String {
                preferencesService.set(tamilFontColor, forKey: "tamilFontColor", local: false)
            } else {
                preferencesService.set(ColorUtils.Color.red.rawValue, forKey: "tamilFontColor", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "englishFontColor", local: false) {
            if let englishFontColor = preferencesService.object(forKey: "englishFontColor", local: true) as? String {
                preferencesService.set(englishFontColor, forKey: "englishFontColor", local: false)
            } else {
                preferencesService.set(ColorUtils.Color.darkGray.rawValue, forKey: "englishFontColor", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "presentationTamilFontColor", local: false) {
            if let presentationTamilFontColor = preferencesService.object(forKey: "presentationTamilFontColor", local: true) as? String {
                preferencesService.set(presentationTamilFontColor, forKey: "presentationTamilFontColor", local: false)
            } else {
                preferencesService.set(ColorUtils.Color.red.rawValue, forKey: "presentationTamilFontColor", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "presentationEnglishFontColor", local: false) {
            if let presentationEnglishFontColor = preferencesService.object(forKey: "presentationEnglishFontColor", local: true) as? String {
                preferencesService.set(presentationEnglishFontColor, forKey: "presentationEnglishFontColor", local: false)
            } else {
                preferencesService.set(ColorUtils.Color.white.rawValue, forKey: "presentationEnglishFontColor", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: "presentationBackgroundColor", local: false) {
            if let presentationBackgroundColor = preferencesService.object(forKey: "presentationBackgroundColor", local: true) as? String {
                preferencesService.set(presentationBackgroundColor, forKey: "presentationBackgroundColor", local: false)
            } else {
                preferencesService.set(ColorUtils.Color.black.rawValue, forKey: "presentationBackgroundColor", local: false)

            }
        }
        
        if !preferencesService.isExist(forKey: CommonConstansts.favorite, local: false) {
            updateFavoriteSongs(local: true)
        } else {
            updateFavoriteSongs(local: false)
        }
        
        if let latestFavoriteUpdated = preferencesService.object(forKey: "latestFavoriteUpdated", local: false) as? Bool {
            if !latestFavoriteUpdated {
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: [FavoritesSongsWithOrder]())
                preferencesService.set(encodedData, forKey: CommonConstansts.favorite, local: false)
                preferencesService.set(true, forKey: "latestFavoriteUpdated", local: false)
            }
        }
        
        if !preferencesService.isExist(forKey: CommonConstansts.favorites, local: false) {
            if let favoriteList = preferencesService.object(forKey: CommonConstansts.favorites, local: true) as? [String] {
                preferencesService.set(favoriteList, forKey: CommonConstansts.favorites, local: false)
            } else {
                var favorites = [String]()
                favorites.append(CommonConstansts.favorite)
                preferencesService.set(favorites, forKey: CommonConstansts.favorites, local: false)
            }
        }
        
        if !preferencesService.isExist(forKey: "rateUsDate", local: false) {
            let calendar = NSCalendar.current
            let date = calendar.date(byAdding: .day, value: 0, to: Date())!
            preferencesService.set(date, forKey: "rateUsDate", local: false)
        }
        
        
    }
    
    fileprivate func updateFavoriteSongs(local: Bool) {
        if let favSongs = preferencesService.object(forKey: CommonConstansts.favorite, local: local) as? [String] {
            var favoritesSongsWithOrders = [FavoritesSongsWithOrder]()
            for i in 0..<favSongs.count {
                favoritesSongsWithOrders.append(FavoritesSongsWithOrder(orderNo: i, songName: favSongs[i], songListName: CommonConstansts.favorite))
            }
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favoritesSongsWithOrders)
            preferencesService.set(encodedData, forKey: CommonConstansts.favorite, local: false)
            preferencesService.set(true, forKey: "latestFavoriteUpdated", local: false)
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

