//
//  LyricsXmlParser.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 14/02/2019.
//  Copyright © 2019 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class LyricsXmlParser: NSObject, XMLParserDelegate {
    
    var element:String!
    var attribues : NSDictionary = NSDictionary()
    var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    var verseOrderList: NSMutableArray = NSMutableArray()
    
    func parse(song: Songs) -> (NSMutableDictionary, NSMutableArray){
        element = ""
        attribues = NSDictionary()
        listDataDictionary = NSMutableDictionary()
        parsedVerseOrderList = NSMutableArray()
        verseOrderList = NSMutableArray()
        let lyrics: Data = song.lyrics.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let parser = XMLParser(data: lyrics)
        parser.delegate = self
        parser.parse()
        if(verseOrderList.count < 1){
            print("parsedVerseOrderList:\(parsedVerseOrderList)")
            verseOrderList = parsedVerseOrderList
        }
        return (listDataDictionary, verseOrderList)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict as NSDictionary
        print("attribues:\(attribues)")
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("string:\(string)")
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("data:\(data)")
        if (!data.isEmpty) {
            if element == "verse" {
                let verseType = (attribues.object(forKey: "type") as! String).lowercased()
                let verseLabel = attribues.object(forKey: "label")as! String
                //lyricsData.append(data);
                listDataDictionary.setObject(data as String, forKey: verseType.appending(verseLabel) as NSCopying)
                if(verseOrderList.count < 1){
                    parsedVerseOrderList.add(verseType + verseLabel)
                    print("parsedVerseOrder:\(parsedVerseOrderList)")
                }
            }
        }
    }
}
