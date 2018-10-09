//
//  DatabaseService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 27/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import Foundation

class DatabaseService {
    
    fileprivate let commonService = CommonService()
    let preferences = UserDefaults.standard
    
    func restoreDatabase() {
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        
        if FileManager.default.fileExists(atPath: defaultUrl) {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: defaultUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
            try! FileManager.default.removeItem(atPath: cacheUrl)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
        }
        self.preferences.set(true, forKey: "defaultDatabase")
        self.preferences.synchronize()
    }
    
    func revertImport() {
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if FileManager.default.fileExists(atPath: defaultUrl) {
            try! FileManager.default.removeItem(atPath: defaultUrl)
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: cacheUrl) as URL, to: NSURL(fileURLWithPath: defaultUrl) as URL)
        } else {
            try! FileManager.default.removeItem(atPath: databaseUrl)
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: cacheUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        }
    }
    
    func revertUpdate() {
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if FileManager.default.fileExists(atPath: databaseUrl) {
            try! FileManager.default.removeItem(atPath: databaseUrl)
        }
        if FileManager.default.fileExists(atPath: cacheUrl) {
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: cacheUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        } else {
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: defaultUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
            self.preferences.set(true, forKey: "defaultDatabase")
            self.preferences.synchronize()
        }
    }
    
    func importDatabase(url: URL) {
        self.preferences.set(true, forKey: "database.lock")
        self.preferences.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil,  userInfo: nil)
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if !FileManager.default.fileExists(atPath: defaultUrl) {
            try! FileManager.default.copyItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: defaultUrl) as URL)
            Downloader.load(url: url , to: NSURL(fileURLWithPath: databaseUrl) as URL, completion: {
                () -> Void in
            })
        } else {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.copyItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            Downloader.load(url: url , to: NSURL(fileURLWithPath: databaseUrl) as URL, completion: {
                () -> Void in
                
            })
        }
    }
    
    func updateDatabase(url: URL) {
        self.preferences.set(true, forKey: "update.lock")
        self.preferences.synchronize()
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if FileManager.default.fileExists(atPath: defaultUrl) {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.copyItem(at: NSURL(fileURLWithPath: defaultUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            UpdateService.load(url: url , to: NSURL(fileURLWithPath: defaultUrl) as URL, completion: {
                () -> Void in
            })
        } else {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.copyItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            UpdateService.load(url: url , to: NSURL(fileURLWithPath: databaseUrl) as URL, completion: {
                () -> Void in
                
            })
        }
    }
    
    func checkForUpdate(url: URL) {
        
    }
    
    func copyBundledDatabase(_ fileName: NSString) {
        print("File copy started")
        var dbPath: String = commonService.getDocumentDirectoryPath(fileName as String)
        let dbBakPath: String = commonService.getDocumentDirectoryPath("songs-bak.sqlite" as String)
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: dbBakPath) {
                try fileManager.removeItem(atPath: dbBakPath)
                dbPath = dbBakPath
            } else if fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(atPath: dbPath)
            }
            let fromPath: String? = Bundle.main.resourcePath?.stringByAppendingPathComponent(fileName as String)
            try fileManager.copyItem(atPath: fromPath!, toPath: dbPath)
            print("File copied successfully in \(dbPath)")
        } catch let error as NSError {
            print("Error occurred while copy \(dbPath): \(error)")
        }
        
    }
    
    func importDriveDatabase(url: URL) {
        self.preferences.set(true, forKey: "database.lock")
        self.preferences.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil,  userInfo: nil)
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if !FileManager.default.fileExists(atPath: defaultUrl) {
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: defaultUrl) as URL)
            try! FileManager.default.copyItem(at: url, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        } else {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            try! FileManager.default.copyItem(at: url, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        }
        preferences.setValue("imported.sucessfully", forKey: "import.status")
        preferences.set(false, forKey: "defaultDatabase")
        preferences.set(false, forKey: "database.lock")
        preferences.synchronize()
    }
    
    func verifyDatabase() -> Bool {
        let databaseHelper = DatabaseHelper()
        let songModel = databaseHelper.getSongModel()
        return songModel.count > 0
    }
    
}
