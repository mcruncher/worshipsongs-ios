//
//  SongsTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/12/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class SongsTableViewController: UITableViewController, XMLParserDelegate{
    
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
        let lyrics: Data = songLyrics.data(using: String.Encoding.utf8.rawValue)!
        let parser = XMLParser(data: lyrics)
        parser.delegate = self
        parser.parse()
        if(verseOrderList.count < 1){
            print("parsedVerseOrderList:\(parsedVerseOrderList)")
            verseOrderList = parsedVerseOrderList
        }
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("row\(self.verseOrderList.count)")
        return self.verseOrderList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 1
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       // cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        let key: String = (verseOrderList[(indexPath as NSIndexPath).section] as! String).lowercased()
        print("key\(key)")
        let dataText: NSString? = listDataDictionary[key] as? NSString
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!);
        print("cell\(cell.textLabel!.attributedText )")
        return cell
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict as NSDictionary
        print("attribues:\(attribues)")
        
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text = string
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
