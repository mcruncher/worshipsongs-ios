//
//  UserDefaultsSettingsProviderService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/9/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation

import UIKit
import SystemConfiguration

class UserDefaultsSettingsProviderService: NSObject {
    
    func getUserDefaultFont() -> NSDictionary {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        let fontName = settingDataManager.getFontName
        let font = UIFont(name: settingDataManager.getFontName, size: settingDataManager.getFontSize) ?? UIFont.systemFontOfSize(18.0)
        let textFont = [NSFontAttributeName:font]
        return textFont
    }
    
    func keepAwakeScreenDisplayStatus() -> Bool {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        let keepAwakeStatus = settingDataManager.getKeepAwake
        return keepAwakeStatus
    }
    
    func getUserDefaultsColor(key: NSString) -> UIColor{
        let userSelectedSecondaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedSecondaryColorData!) as UIColor
    }
    
    
}