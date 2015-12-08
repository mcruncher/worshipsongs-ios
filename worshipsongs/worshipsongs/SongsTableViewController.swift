//
//  SongsTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/12/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class SongsTableViewController: UITableViewController, NSXMLParserDelegate{
    
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    
    var songName: String = ""
    var songLyrics: NSString = NSString()
    var verseOrder: NSArray = NSArray()
    var element:String!
    var attribues : NSDictionary = NSDictionary()
    var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    var verseOrderList: NSMutableArray = NSMutableArray()
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = songName
        let lyrics: NSData = songLyrics.dataUsingEncoding(NSUTF8StringEncoding)!
        let parser = NSXMLParser(data: lyrics)
        parser.delegate = self
        parser.parse()
        if(verseOrderList.count < 1){
            print("parsedVerseOrderList:\(parsedVerseOrderList)")
            verseOrderList = parsedVerseOrderList
        }
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("row\(self.verseOrderList.count)")
        return self.verseOrderList.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 1
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
       // cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        let key: String = (verseOrderList[indexPath.section] as! String).lowercaseString
        print("key\(key)")
        let dataText: NSString? = listDataDictionary[key] as? NSString
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!);
        print("cell\(cell.textLabel!.attributedText )")
        return cell
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict
        print("attribues:\(attribues)")
        
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        text = string
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
                    print("parsedVerseOrder:\(parsedVerseOrderList)")
                }
            }
        }
    }

}
