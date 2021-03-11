//
//  PDFMessageParser.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 14/02/2019.
//  Copyright © 2019 Vignesh Palanisamy. All rights reserved.
//

import UIKit

struct MessageParser {
    
    fileprivate static let preferences = UserDefaults.standard
    fileprivate static let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    
    static func getMessageToShare(_ song: Songs, _ verseOrderList: NSMutableArray, _ listDataDictionary : NSMutableDictionary) -> NSMutableAttributedString {
        let isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "Tamil Christian Worship Songs\n\n"))
        if isLanguageTamil && !song.i18nTitle.isEmpty{
            objectString.append(NSAttributedString(string: "\n\(song.i18nTitle)\n\n"))
        } else {
            objectString.append(NSAttributedString(string: "\n\(song.title)\n\n"))
        }
        objectString.append(getVerses(verseOrderList, listDataDictionary))
        objectString.append(NSAttributedString(string: "\n"))
        return objectString
    }
    
    static func getVerses(_ verseOrderList: NSMutableArray, _ listDataDictionary : NSMutableDictionary) -> NSMutableAttributedString {
        let verseString: NSMutableAttributedString = NSMutableAttributedString()
        for verseOrder in verseOrderList {
            verseString.append(getMessage(verseOrder as! String, listDataDictionary))
        }
        return verseString
    }
    
    static func getMessage(_ verseOrder: String, _ listDataDictionary : NSMutableDictionary) ->  NSMutableAttributedString{
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        let key: String = (verseOrder).lowercased()
        let dataText: String? = listDataDictionary[key] as? String
        let texts = parseString(dataText!)
        print("verseOrder \(verseOrder)")
        for text in texts {
            objectString.append(NSAttributedString(string: text))
            objectString.append(NSAttributedString(string: "\n"))
        }
        objectString.append(NSAttributedString(string: "\n"))
        return objectString
    }
    
    static func parseString(_ text: String) -> [String] {
        let attributeText = customTextSettingService.getAttributedString(text as NSString)
        //    let parsedText = attributeText.string.replacingOccurrences(of: "\n", with: "\n{n}")
        return attributeText.string.components(separatedBy: "\n")
    }
    
    static func getObjectToShare(_ song: Songs, _ verseOrderList: NSMutableArray, _ listDataDictionary : NSMutableDictionary) -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "<html><body>"))
        objectString.append(NSAttributedString(string: "<h1><a href=\"https://itunes.apple.com/us/app/tamil-christian-worship-songs/id1066174826?mt=8\">Tamil Christian Worship Songs</a></h1>"))
        let isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        if isLanguageTamil && !song.i18nTitle.isEmpty {
            objectString.append(NSAttributedString(string: "<h2>\(song.i18nTitle)</h2>"))
        } else {
            objectString.append(NSAttributedString(string: "<h2>\(song.title)</h2>"))
        }
        for verseOrder in verseOrderList {
            objectString.append(getObject(verseOrder as! String, listDataDictionary))
        }
        objectString.append(NSAttributedString(string: "<br/>"))
        objectString.append(NSAttributedString(string: "</body></html>"))
        return objectString
    }
    
    static func getObject(_ verseOrder: String, _ listDataDictionary : NSMutableDictionary) -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        let key: String = verseOrder.lowercased()
        let dataText: String? = listDataDictionary[key] as? String
        let texts = parseString(dataText!)
        print("verseOrder \(verseOrder)")
        for text in texts {
            objectString.append(NSAttributedString(string: text))
            objectString.append(NSAttributedString(string: "<br/>"))
        }
        objectString.append(NSAttributedString(string: "<br/>"))
        return objectString
    }
}
