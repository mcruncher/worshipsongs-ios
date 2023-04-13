//
// author: Madasamy, Vignesh Palanisamy
// version: 1.0.0
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
    //var text: String!
    fileprivate let preferences = NSUbiquitousKeyValueStore.default

    override func viewDidLoad() {
        super.viewDidLoad()
        addShareBarButton()
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
        self.onChangeOrientation(orientation: UIDevice.current.orientation)
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
        let key: String = (verseOrderList[(indexPath as NSIndexPath).section] as! String).lowercased()
        print("key\(key)")
        let dataText: NSString? = listDataDictionary[key] as? NSString
        cell.textLabel!.numberOfLines = 0
        if let fontSize = self.preferences.object(forKey: "fontSize") as? Int {
            cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!)
        return cell
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict as NSDictionary
        print("attribues:\(attribues)")
        
    }
    
    fileprivate func addShareBarButton() {
        self.navigationController!.navigationBar.tintColor = UIColor.gray
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Share"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTableViewController.share))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func fullScreen() {
        performSegue(withIdentifier: "fullScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "fullScreen") {
            let transition = CATransition()
            transition.duration = 0.75
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.navigationController!.view.layer.add(transition, forKey: nil)
            let fullScreenController = segue.destination as! FullScreenViewController
            fullScreenController.cells = getAllCells()
            fullScreenController.songName = songName
        }
    }
    
    @objc func share() {
        let emailMessage = getObjectToShare()
        let messagerMessage = getMessageToShare()
        let firstActivityItem = CustomProvider(placeholderItem: "Default" as AnyObject, messagerMessage: messagerMessage.string, emailMessage: emailMessage.string)
        if let myWebsite = URL(string: "https://itunes.apple.com/us/app/tamil-christian-worship-songs/id1066174826?mt=8") {
            let objectsToShare = [firstActivityItem, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.setValue("Tamil Christian Worship Songs " + songName, forKey: "Subject")
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.postToFacebook, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
            
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    class CustomProvider : UIActivityItemProvider {
        var messagerMessage : String!
        var emailMessage : String!
        
        init(placeholderItem: AnyObject, messagerMessage : String, emailMessage : String) {
            super.init(placeholderItem: placeholderItem)
            self.messagerMessage = messagerMessage
            self.emailMessage = emailMessage
        }
        
        override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
            if activityType == UIActivityType.message {
                return messagerMessage as AnyObject?
            } else if activityType == UIActivityType.mail {
                return emailMessage as AnyObject?
            } else if activityType == UIActivityType.postToTwitter {
                return NSLocalizedString(messagerMessage, comment: "comment")
            }else {
                return emailMessage as AnyObject?
            }
        }
    }
    
    func getObjectToShare() -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "<html><body>"))
        objectString.append(NSAttributedString(string: "<h1><a href=\"https://itunes.apple.com/us/app/tamil-christian-worship-songs/id1066174826?mt=8\">Tamil Christian Worship Songs</a></h1>"))
        objectString.append(NSAttributedString(string: "<h2>\(songName)</h2>"))
        for verseOrder in verseOrderList {
            let key: String = (verseOrder as! String).lowercased()
            let dataText: String? = listDataDictionary[key] as? String
            let texts = parseString(text: dataText!)
            print("verseOrder \(verseOrder)")
            for text in texts {
                objectString.append(NSAttributedString(string: text))
                objectString.append(NSAttributedString(string: "<br/>"))
            }
        }
        objectString.append(NSAttributedString(string: "</body></html>"))
        return objectString
    }
    
    func parseString(text: String) -> [String] {
        var parsedText = text.replacingOccurrences(of: "{/y}", with: "{y} ")
        print(parsedText)
        parsedText.append("{y}")
        return parsedText.components(separatedBy: "{y}")
    }
    
    func getMessageToShare() -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "Tamil Christian Worship Songs\n\n"))
        objectString.append(NSAttributedString(string: "\n\(songName)\n\n"))
        for verseOrder in verseOrderList {
            let key: String = (verseOrder as! String).lowercased()
            let dataText: String? = listDataDictionary[key] as? String
            let texts = parseString(text: dataText!)
            print("verseOrder \(verseOrder)")
            for text in texts {
                objectString.append(NSAttributedString(string: text))
            }
            objectString.append(NSAttributedString(string: "\n\n"))
        }
        return objectString
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //text = string
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
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.onChangeOrientation(orientation: UIDevice.current.orientation)
    }
    
    func onChangeOrientation(orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        case .landscapeRight:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            fullScreen()
        case .landscapeLeft:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            fullScreen()
        default:
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    func getAllCells() -> [UITableViewCell] {
        
        var cells = [UITableViewCell]()
        // assuming tableView is your self.tableView defined somewhere
        for i in 0...self.verseOrderList.count-1
        {
            let key: String = (verseOrderList[i] as! String).lowercased()
            let dataText: NSString? = listDataDictionary[key] as? NSString
            let cell = UITableViewCell()
            if let fontSize = self.preferences.object(forKey: "fontSize") as? Int {
                cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize + 5))
            }
            cell.textLabel!.numberOfLines = 0
            cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!);
            cells.append(cell)
        }
        return cells
    }

}



