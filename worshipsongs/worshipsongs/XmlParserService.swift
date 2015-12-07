//
//  XmlParserService.swift
//  worshipsongs
//
//  Created by Sundar & Vicky on 20/10/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

private class ParserDelegate:NSObject, NSXMLParserDelegate{
    
    init(element:String){
       // self.element=element
        super.init()
    }
    
    var element:String!
    var attribues : NSDictionary = NSDictionary()
    var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    var verseOrderList: NSMutableArray = NSMutableArray()
    

    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict
        print("attribues:\(attribues)")
        
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        print("string:\(string)")
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        print("data:\(data)")
        if (!data.isEmpty) {
            if element == "verse" {
                let verseType = (attribues.objectForKey("type") as! String).lowercaseString
                let verseLabel = attribues.objectForKey("label")as! String
                //lyricsData.append(data);
                listDataDictionary.setObject(data as String, forKey: verseType + verseLabel)
                if(verseOrderList.count < 1){
                    parsedVerseOrderList.addObject(verseType + verseLabel)
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
    
    private var xmlString: NSString
  //  var returnValue:String?
    var verseOrderList: NSMutableArray = NSMutableArray()
    private var parserDelegate:ParserDelegate
    
    func parse()->Bool{
        print("parse")
        let lyrics: NSData = xmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        let parser = NSXMLParser(data: lyrics)
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