//
//  ViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/18/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit

let FONT_SIZE = 14.0
let CELL_CONTENT_WIDTH = 320.0
let CELL_CONTENT_MARGIN = 10.0

class ViewController: UIViewController, UITableViewDataSource, NSXMLParserDelegate {
    
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    let textAttributeService:TextAttributeService = TextAttributeService()
    let userDefaultsSettingsProviderService:UserDefaultsSettingsProviderService = UserDefaultsSettingsProviderService()
    var tableView:UITableView!
    var parser: NSXMLParser = NSXMLParser()
    
    var songName: String = String()
    var songLyrics = NSString()
    var lyricsData = [String]()
    var verseOrderList: NSMutableArray = NSMutableArray()
    var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    var element: String = String()
    
    
    var verseOrder : NSMutableArray = NSMutableArray()
    var attribues : NSDictionary = NSDictionary()
    
    var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        if(userDefaultsSettingsProviderService.keepAwakeScreenDisplayStatus()){
            UIApplication.sharedApplication().idleTimerDisabled = true
        }
        self.navigationItem.title = songName;
        //self.navigationController?.navigationBar.tintColor = UIColor.blackColor();
        //self.navigationController?.navigationBar.titleTextAttributes = textAttributeService.getDefaultTextAttributes()
        var myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
            self.view.bounds.size.width, self.view.bounds.size.height);
        self.view.frame = myFrame
        
        var lyrics: NSData = songLyrics.dataUsingEncoding(NSUTF8StringEncoding)!
        parser = NSXMLParser(data: lyrics)
        parser.delegate = self
        parser.parse()
        if(verseOrderList.count < 1){
            verseOrderList = parsedVerseOrderList
        }
        self.tableView = UITableView(frame:self.view!.frame)
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        self.tableView.allowsSelection = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CELL_ID")
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: nil, action: nil)
        var toolbarButtons = [plusButton];
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default // UIBarStyleBlackTranslucent was deprecated in iOS 3
        toolbar.translucent = true;
        toolbar.frame = CGRectMake(0, self.tableView.frame.size.height - 46, self.tableView.frame.size.width, 46)
        toolbar.sizeToFit()
        toolbar.setItems(toolbarButtons, animated: true)
       
        
        // Reload the table
        self.tableView.reloadData()
        self.view.addSubview(tableView)
        //self.view.addSubview(toolbar)
        

    }
    
    func tableView(tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.25;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.verseOrderList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var dataCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(dataCell == nil)
        {
            dataCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        
        //println("listDataDictionary: \(listDataDictionary)")
        
        var key: String = (verseOrderList[indexPath.section] as String).lowercaseString
        let dataText: NSString? = listDataDictionary[key] as? NSString;
        dataCell!.textLabel!.numberOfLines = 0
        dataCell!.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        
        dataCell!.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!);
        return dataCell!
    }
    
    // MARK: - NSXMLParserDelegate methods
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        element = elementName
        attribues = attributeDict
       
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (!data.isEmpty) {
            if element == "verse" {
                var verseType = (attribues.objectForKey("type") as String).lowercaseString
                var verseLabel = attribues.objectForKey("label") as String
                lyricsData.append(data);
                listDataDictionary.setObject(data as String, forKey: verseType + verseLabel)
                if(verseOrderList.count < 1){
                    parsedVerseOrderList.addObject(verseType + verseLabel)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addSettingsButton ()
    {
        let image = UIImage(named: "Settings@2x.png") as UIImage!
        var settingsButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        settingsButton.frame = CGRectMake(0, 0, 20, 20)
        settingsButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.setImage(image, forState: .Normal)
       // settingsButton.setTitle("Settings", forState: UIControlState.Normal)
        settingsButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
       // settingsButton.sizeToFit()
        var settingsBarButton:UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.setRightBarButtonItem(settingsBarButton, animated: true)
    }
    
    func popToRoot(sender:UIBarButtonItem){
        let settingViewController = SettingViewController(style:UITableViewStyle.Grouped)
        self.navigationController?.pushViewController(settingViewController, animated: true);
    }
}

