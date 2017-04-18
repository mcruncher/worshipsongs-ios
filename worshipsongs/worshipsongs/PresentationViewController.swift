//
//  PresentationViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 01/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class PresentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var secondWindow: UIWindow?
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    let presentationData = PresentationData()
    var songName: String = ""
    var authorName = ""
    var songLyrics: NSString = NSString()
    var verseOrder: NSArray = NSArray()
    var element:String!
    var attribues : NSDictionary = NSDictionary()
    var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    var verseOrderList: NSMutableArray = NSMutableArray()
    var text: String!
    var presentationIndex = 0
    var comment: String = ""
    fileprivate let preferences = UserDefaults.standard
    var play = false
    
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
        presentationData.setupScreen()
        previousButton.layer.cornerRadius = previousButton.layer.frame.height / 2
        previousButton.clipsToBounds = true
        previousButton.isHidden = true
        nextButton.layer.cornerRadius = previousButton.layer.frame.height / 2
        nextButton.clipsToBounds = true
        nextButton.isHidden = self.verseOrder.count <= 1
        self.preferences.setValue(authorName, forKeyPath: "presentationAuthor")
        self.preferences.setValue(songName, forKeyPath: "presentationSongName")
        self.preferences.synchronize()
        let backButton = UIBarButtonItem(title: "back".localized, style: .plain, target: self, action: #selector(PresentationViewController.goBackToSongsList))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func goBackToSongsList() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 0))
        footerview.backgroundColor = UIColor.groupTableViewBackground
        return footerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        goto(IndexPath(row: 0, section: 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("row\(self.verseOrderList.count)")
        return self.verseOrderList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goto(indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key: String = (verseOrderList[(indexPath as NSIndexPath).section] as! String).lowercased()
        print("key\(key)")
        let dataText: NSString? = listDataDictionary[key] as? NSString
        cell.textLabel!.numberOfLines = 0
        let fontSize = self.preferences.integer(forKey: "fontSize")
        cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!)
        print("cell\(cell.textLabel!.attributedText )")
        return cell
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict as NSDictionary
        print("attribues:\(attribues)")
        
    }
    
    @IBAction func goToPrevious(_ sender: Any) {
        var indexPath = IndexPath(row: 0, section: 0)
        if tableView.indexPathForSelectedRow != nil {
            indexPath = IndexPath(row: (tableView.indexPathForSelectedRow?.row)!, section: (tableView.indexPathForSelectedRow?.section)! - 1)
        }
        goto(indexPath)
    }
    
    @IBAction func goToNext(_ sender: Any) {
        var indexPath = IndexPath(row: 0, section: 0)
        if tableView.indexPathForSelectedRow != nil {
            indexPath = IndexPath(row: (tableView.indexPathForSelectedRow?.row)!, section: (tableView.indexPathForSelectedRow?.section)! + 1)
        }
        goto(indexPath)
    }
    
    func goto(_ indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        let key = (verseOrderList[(indexPath as NSIndexPath).section] as! String).lowercased()
        let dataText: NSString? = listDataDictionary[key] as? NSString
        self.preferences.setValue(dataText, forKey: "presentationLyrics")
        let slideNumber = String(indexPath.section + 1) + " of " + String(tableView.numberOfSections)
        self.preferences.setValue(slideNumber, forKeyPath: "presentationSlide")
        self.preferences.synchronize()
        self.presentationData.updateScreen()
        previousButton.isHidden = indexPath.section <= 0
        nextButton.isHidden = indexPath.section >= tableView.numberOfSections - 1
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
