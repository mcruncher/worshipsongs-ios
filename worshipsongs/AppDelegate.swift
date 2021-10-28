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
    fileprivate let preferences = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        notificationCenterService = NotificationCenterService()
        UINavigationBar.appearance().tintColor = UIColor.cruncherBlue()
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
        var favoriteList = (preferences.array(forKey: CommonConstansts.favorites) as? [String])!
        if !favoriteList.contains(favoriteName) {
            favoriteList.append(favoriteName)
            self.preferences.set(favoriteList, forKey: CommonConstansts.favorites)
            self.preferences.synchronize()
        }
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favoritesSongsWithOrders)
        self.preferences.set(encodedData, forKey: favoriteName)
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
        self.preferences.setValue("", forKey: "import.status")
        self.preferences.setValue("", forKey: "update.status")
        self.preferences.setValue("", forKey: "presentationSongName")
        self.preferences.setValue("", forKey: "presentationLyrics")
        self.preferences.setValue("", forKey: "presentationSlide")
        self.preferences.setValue(0, forKey: "presentationSlideNumber")
        self.preferences.setValue("", forKey: "presentationAuthor")
        self.preferences.synchronize()
        
        if !preferences.dictionaryRepresentation().keys.contains("displayRomanised") {
            self.preferences.set(true, forKey: "displayRomanised")
            self.preferences.synchronize()
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("displayTamil") {
            self.preferences.set(true, forKey: "displayTamil")
            self.preferences.synchronize()
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("sha") {
            self.preferences.set("no_sha", forKey: "sha")
            self.preferences.synchronize()
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("searchBy") {
            self.preferences.set("searchByTitle", forKey: "searchBy")
            self.preferences.synchronize()
        }
        
        if !preferences.dictionaryRepresentation().keys.contains(CommonConstansts.searchKey) {
            self.preferences.set(CommonConstansts.searchByTitleOrNumber, forKey: CommonConstansts.searchKey)
            self.preferences.synchronize()
        }
    
        if !preferences.dictionaryRepresentation().keys.contains("database.lock") {
            self.preferences.set(false, forKey: "database.lock")
            self.preferences.synchronize()
        } else {
            if preferences.bool(forKey: "database.lock") {
                let databaseService = DatabaseService()
                databaseService.revertImport()
                preferences.set(false, forKey: "database.lock")
                preferences.synchronize()
                notificationCenterService.post(name: "refreshTabbar", userInfo: nil)
            }
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("update.lock") {
            self.preferences.set(false, forKey: "update.lock")
            self.preferences.synchronize()
        } else {
            if preferences.bool(forKey: "update.lock") {
                let databaseService = DatabaseService()
                databaseService.revertUpdate()
                preferences.set(false, forKey: "update.lock")
                preferences.synchronize()
                notificationCenterService.post(name: "refreshTabbar", userInfo: nil)
            }
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("check.update.url") {
            self.preferences.setValue("https://api.github.com/repos/mcruncher/worshipsongs-db-dev/git/refs/heads/master", forKey: "check.update.url")
            self.preferences.synchronize()
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("update.url") {
            self.preferences.setValue("https://github.com/mcruncher/worshipsongs-db-dev/raw/master/songs.sqlite", forKey: "update.url")
            self.preferences.synchronize()
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
        
        if !preferences.dictionaryRepresentation().keys.contains("favorites") {
            var favorites = [String]()
            favorites.append("favorite")
            self.preferences.set(favorites, forKey: "favorites")
            self.preferences.synchronize()
        }
        
        if !preferences.dictionaryRepresentation().keys.contains("rateUsDate") {
            let calendar = NSCalendar.current
            let date = calendar.date(byAdding: .day, value: 0, to: Date())!
            self.preferences.set(date, forKey: "rateUsDate")
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

