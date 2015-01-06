//
//  SettingsDataManager.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/26/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class SettingsDataManager {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var fontName: String = String()
    var fontSize: CGFloat = CGFloat()
    var primaryFontColor: NSData = NSData()
    var secondaryFontColor: NSData = NSData()
    var keepAwake: Bool = Bool()
    var latestChangeSet: NSString = NSString()
    
    struct Static {
        static var onceToken : dispatch_once_t = 0
        static var instance : SettingsDataManager? = nil
    }
    
    class var sharedInstance : SettingsDataManager {
        dispatch_once(&Static.onceToken) {
            Static.instance = SettingsDataManager()
        }
        return Static.instance!
    }

    
    var getFontName: String {
        return fontName
    }
    
    var getFontSize: CGFloat {
        return fontSize
    }
    
    var getPrimaryFontColor: UIColor {
        let userSelectedPrimaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("primaryFontColor") as? NSData
        var colorValue: UIColor = UIColor()
        colorValue = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedPrimaryColorData!) as UIColor
        return colorValue
    }
    
    var getSecondaryFontColor: UIColor {
        
        let userSelectedSecondaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("secondaryFontColor") as? NSData
        var colorValue: UIColor = UIColor()
        colorValue = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedSecondaryColorData!) as UIColor
        return colorValue
    }
    
    var getKeepAwake: Bool {
        return keepAwake
    }
    
    var getLatestChangeSet: NSString{
        latestChangeSet = NSUserDefaults.standardUserDefaults().objectForKey("latestChangeSet") as NSString!
        return latestChangeSet;
    }
    
    init() {
        setFontNameDefault()
        setFontSizeDefault()
        setPrimaryFontColorDefault()
        setSecondaryFontColorDefault()
        setkeepAwakeDefault()
        setLatestChangeSet()
    }
    
    func setFontNameDefault()
    {
        if let fontNameInfo = userDefaults.valueForKey("fontName") as? String {
            fontName = fontNameInfo
        } else {
            // add default data
            fontName = "HelveticaNeue"
        }
    }
    
    func setFontSizeDefault()
    {
        if let fontSizeInfo = userDefaults.valueForKey("fontSize") as? CGFloat {
            fontSize = fontSizeInfo
        } else {
            // add default data
            fontSize = CGFloat(12)
        }
    }
    
    func setPrimaryFontColorDefault()
    {
        if let primaryFontColorInfo = userDefaults.valueForKey("primaryFontColor") as? NSData {
            primaryFontColor = primaryFontColorInfo
        } else {
            // add default data
            var colorToSetAsDefault : UIColor = UIColor.blackColor()
            var data : NSData = NSKeyedArchiver.archivedDataWithRootObject(colorToSetAsDefault)
            userDefaults.setObject(data, forKey: "primaryFontColor")
            userDefaults.synchronize()
        }
    }
    
    func setSecondaryFontColorDefault()
    {
        if let secondaryFontColorInfo = userDefaults.valueForKey("secondaryFontColor") as? NSData {
            secondaryFontColor = secondaryFontColorInfo
        } else {
            // add default data
            var colorToSetAsDefault : UIColor = UIColor.blackColor()
            var data : NSData = NSKeyedArchiver.archivedDataWithRootObject(colorToSetAsDefault)
            userDefaults.setObject(data, forKey: "secondaryFontColor")
            userDefaults.synchronize()
        }
    }
    
    func setkeepAwakeDefault()
    {
        if let keepAwakeInfo = userDefaults.valueForKey("keepAwake") as? Bool {
            keepAwake = keepAwakeInfo
        } else {
            // add default data
            keepAwake = true
        }
    }
    
    func setLatestChangeSet()
    {
        if var latestChangeSetValue = userDefaults.valueForKey("latestChangeSet") as? NSString {
            latestChangeSet = latestChangeSetValue
        } else {
            // add default data
            latestChangeSet = ""
        }
    }
    
    func saveData(value: AnyObject, key: String) {
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    
    func reset() {
        userDefaults.removeObjectForKey("fontName")
        userDefaults.removeObjectForKey("fontSize")
        userDefaults.removeObjectForKey("primaryFontColor")
        userDefaults.removeObjectForKey("secondaryFontColor")
        userDefaults.removeObjectForKey("keepAwake")
        setAllValues()
    }

    func setAllValues(){
         println("Set all default values...")
        setFontNameDefault()
        setFontSizeDefault()
        setPrimaryFontColorDefault()
        setSecondaryFontColorDefault()
        setkeepAwakeDefault()
    }
    
}