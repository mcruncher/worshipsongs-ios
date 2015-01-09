//
//  Util.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/19/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit
import SystemConfiguration

class Util: NSObject {
    
    let settingDataManager:SettingsDataManager = SettingsDataManager()
    let commonService:CommonService = CommonService()

    func copyFile(fileName: NSString) {
        var dbPath: String = commonService.getDocumentDirectoryPath(fileName)
        var fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            var fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(fileName)
            fileManager.copyItemAtPath(fromPath!, toPath: dbPath, error: nil)
        }
    }
    
    func invokeAlertMethod(strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
        var alert: UIAlertView = UIAlertView()
        alert.message = strBody
        alert.title = strTitle
        alert.delegate = delegate
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func downloadFile()
    {
        let latestChangeSetInUserDefults  = NSUserDefaults.standardUserDefaults().objectForKey("latestChangeSet") as NSString!
        var latestChangeSet = parseJson()
        if (latestChangeSetInUserDefults == nil)
        {
            startDownload(latestChangeSet)
        }
        else if(!latestChangeSet.isEqualToString(latestChangeSetInUserDefults)){
            startDownload(latestChangeSet)
        }
        else{
            println("Changeset are same no need to download")
        }
    }
    
    
    func parseJson() -> NSString{
        let url=NSURL(string:"https://api.github.com/repos/crunchersaspire/worshipsongs-db/commits/master")
        let jsonData=NSData(contentsOfURL:url!)
        var err: NSError?
        var latestChangeSetValue: NSString?
        var dict: NSDictionary=NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error:nil) as NSDictionary
        for (key,value) in dict {
            if(key as NSString == "sha"){
                latestChangeSetValue = value as? NSString;
               // SettingsDataManager.sharedInstance.saveData(latestChangeSetValue, key: "latestChangeSet")
            }
        }
        return latestChangeSetValue!
    }
    
    func startDownload(latestChangeSet:NSString){
        println("Download Startted")
        var writeError: NSError?
        let filemanager = NSFileManager.defaultManager()
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let destinationPath:NSString = documentsPath.stringByAppendingString("/songs.sqlite")
        let myURLstring = "https://github.com/crunchersaspire/worshipsongs-db/blob/master/songs.sqlite?raw=true"
        let myFilePathString = "/Volumes/HD/Staff Pictures/Bob-VEHS.jpg"
        let url = NSURL(string: myURLstring)
        let dataFromURL = NSData(contentsOfURL: url!)
        let fileManager = NSFileManager.defaultManager()
        fileManager.createFileAtPath(destinationPath, contents: dataFromURL, attributes: nil)
        SettingsDataManager.sharedInstance.saveData(latestChangeSet, key: "latestChangeSet")
        println("After save latestChangeSet : \(settingDataManager.getLatestChangeSet)")
        
        if((writeError) != nil){
            NSLog("Error occured while downloading:", writeError!)
        }
    }
    
    
    
    func keepAwakeScreenDisplayStatus() -> Bool {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        let keepAwakeStatus = settingDataManager.getKeepAwake
        return keepAwakeStatus
    }
    
}


