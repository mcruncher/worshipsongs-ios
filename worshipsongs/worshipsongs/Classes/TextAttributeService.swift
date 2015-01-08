//
//  TextAttributeService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class TextAttributeService{

    func getUserDefaultFont() -> NSDictionary {
        let settingDataManager:SettingsDataManager = SettingsDataManager()
        let fontName = settingDataManager.getFontName
        let font = UIFont(name: settingDataManager.getFontName, size: settingDataManager.getFontSize) ?? UIFont.systemFontOfSize(18.0)
        let textFont = [NSFontAttributeName:font]
        return textFont
    }

    func getDefaultFont() -> UIFont{
        return UIFont(name: "HelveticaNeue", size: CGFloat(14))!
    }

    func getDefaultTextAttributes() -> NSDictionary{
        let textFontAttributes = [ NSFontAttributeName: getDefaultFont(),NSForegroundColorAttributeName: UIColor.whiteColor()]
        return textFontAttributes
    }

}
