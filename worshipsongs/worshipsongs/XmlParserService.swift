//
//  XmlParserService.swift
//  worshipsongs
//
//  Created by Sundar & Vicky on 20/10/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

private class ParserDelegate:NSObject, XMLParserDelegate{
    
    init(element:String){
       // self.element=element
        super.init()
    }
    
    var element:String!
    var attribues : NSDictionary = NSDictionary()
    var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    var verseOrderList: NSMutableArray = NSMutableArray()
    

    
    @nonobjc func parser(_ parser: XMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [AnyHashable: Any]!) {
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
                }
            }
        }
    }
    
}

class XMLParserService{
    
    init(xml: NSString, element: String){
        self.xmlString = xml
        self.parserDelegate = ParserDelegate(element:element)
        print("init")
    }
    
    fileprivate var xmlString: NSString
  //  var returnValue:String?
    var verseOrderList: NSMutableArray = NSMutableArray()
    fileprivate var parserDelegate:ParserDelegate
    
    func parse()->Bool{
        print("parse")
        let lyrics: Data = xmlString.data(using: String.Encoding.utf8.rawValue)!
        let parser = XMLParser(data: lyrics)
        parser.delegate = parserDelegate
        if parser.parse() {
            print("parse true")
            verseOrderList = parserDelegate.verseOrderList
            print("verse order \(verseOrderList.count)")
            return true
        }
        return false
    }
    
}
