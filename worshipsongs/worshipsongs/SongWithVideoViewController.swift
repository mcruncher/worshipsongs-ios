//
// author: Madasamy, Vignesh Palanisamy
// version: 1.0.0
//

import UIKit
import YouTubePlayer
import KCFloatingActionButton
import SystemConfiguration
import SimplePDFSwift

class SongWithVideoViewController: UIViewController  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var player: YouTubePlayerView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var playerHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    fileprivate let pdfExtension = ".pdf"
    var secondWindow: UIWindow?
    var secondScreenView: UIView?
    var externalLabel = UILabel()
    var floatingbutton = KCFloatingActionButton()
    var hadYoutubeLink = false
    
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
    var noInternet = false
    fileprivate var isLanguageTamil = true
    
    //new var
    var databaseHelper = DatabaseHelper()
    var selectedSong: Songs! {
        didSet (newSong) {
            self.refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        addFloatButton()
        addShareBarButton()
        setSplitViewControllerProperties()
        setXmlParser()
        hideOrShowComponents()
        setTableViewProperties()
        actionButton.layer.cornerRadius = actionButton.layer.frame.height / 2
        actionButton.clipsToBounds = true
        addLongPressGestureRecognizer()
        setNextButton()
        setPreviousButton()
    }
    
    func refreshUI() {
        let verseOrderString = selectedSong.verse_order
        if !verseOrderString.isEmpty {
            self.verseOrder = splitVerseOrder(verseOrderString)
        }
        songLyrics = selectedSong.lyrics as NSString
        self.songName = selectedSong.title
        authorName = databaseHelper.getArtistName(selectedSong.id)
        if !selectedSong.comment.isEmpty {
            comment = selectedSong.comment
        } else {
            comment = ""
        }
        setXmlParser()
        if DeviceUtils.isIpad() {
            hideOrShowComponents()
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !(DeviceUtils.isIpad()) {
            hideOrShowComponents()
        }
    }
    
    func addFloatButton() {
        let playItem = getKCFloatingActionButtonItem(title: "playSong".localized, icon: UIImage(named: "play")!)
        playItem.handler = { item in
            self.floatingbutton.close()
            if self.isInternetAvailable() {
                if self.noInternet {
                    self.loadYoutube(url: self.selectedSong.mediaUrl)
                    self.noInternet = false
                }
                self.setAction()
            } else {
                self.noInternet = true
                let alertController = self.getAlertController(message: "message.playSong".localized)
                alertController.addAction(self.getCancelAction())
                self.present(alertController, animated: true, completion: nil)
            }
        }
        floatingbutton.addItem(item: playItem)
        let presentationItem = getKCFloatingActionButtonItem(title: "presentSong".localized, icon: UIImage(named: "presentation")!)
        presentationItem.handler = { item in
            self.floatingbutton.close()
            self.presentationData.setupScreen()
            self.presentation(IndexPath(row: 0, section: 0))
        }
        floatingbutton.addItem(item: presentationItem)
        floatingbutton.sticky = true
        floatingbutton.buttonColor = UIColor.red
        floatingbutton.plusColor = UIColor.white
        floatingbutton.size = 50
        self.view.addSubview(floatingbutton)
    }
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    fileprivate func getAlertController(message: String) -> UIAlertController {
        return UIAlertController(title: message, message: "", preferredStyle: UIAlertControllerStyle.alert)
    }
    
    fileprivate func getCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "ok".localized, style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) -> Void in
            self.hideOrShowComponents()
        })
    }
    
    func getKCFloatingActionButtonItem(title: String, icon: UIImage) -> KCFloatingActionButtonItem {
        let item = KCFloatingActionButtonItem()
        item.size = 43
        item.buttonColor = UIColor.cruncherBlue()
        item.title = title
        item.titleColor = UIColor.black
        item.titleLabel.backgroundColor = UIColor.white
        item.titleLabel.layer.cornerRadius = 6
        item.titleLabel.clipsToBounds = true
        item.titleLabel.font = UIFont.systemFont(ofSize: 14)
        item.titleLabel.frame.size.width = item.titleLabel.frame.size.width + 2
        item.titleLabel.frame.size.height = item.titleLabel.frame.size.height + 2
        item.titleLabel.textAlignment = NSTextAlignment.center
        item.icon = icon
        return item
    }
    
    func hideOrShowComponents() {
        if !comment.isEmpty && selectedSong.mediaUrl != "" {
            loadYoutube(url: selectedSong.mediaUrl)
            floatingbutton.isHidden = false
            actionButton.isHidden = true
            hadYoutubeLink = true
        } else {
            floatingbutton.isHidden = true
            actionButton.isHidden = isHideComponent()
            hadYoutubeLink = false
        }
        floatingbutton.close()
        previousButton.isHidden = true
        nextButton.isHidden = true
        player.isHidden = true
        playerHeight.constant = 0
        self.navigationItem.title = isLanguageTamil && !selectedSong.i18nTitle.isEmpty ? selectedSong.i18nTitle : songName
        actionButton.setImage(UIImage(named: "presentation"), for: UIControlState())
        self.tableView.allowsSelection = false
        self.tableView.isHidden = isHideComponent()
        self.tableView.reloadData()
        var indexPath = IndexPath(row:0, section:0)
        let activeSong = preferences.string(forKey: "presentationSongName")
        if activeSong != "" && selectedSong.title == activeSong && UIScreen.screens.count > 1 {
            self.presentationData.setupScreen()
            let activeSection = preferences.integer(forKey: "presentationSlideNumber")
            indexPath = IndexPath(row: 0, section: activeSection)
            self.presentation(indexPath)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
        }
        scrollToRow(indexPath)
        
    }
    
    private func scrollToRow(_ indexPath: IndexPath) {
        if !isHideComponent() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    private func setTableViewProperties() {
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func isHideComponent() -> Bool {
        return verseOrderList.count == 0
    }
    
    private func setSplitViewControllerProperties() {
        if DeviceUtils.isIpad() {
            self.splitViewController!.preferredDisplayMode = .primaryOverlay
            self.splitViewController!.preferredDisplayMode = .allVisible
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadYoutube(url: String) {
        player.playerVars = ["rel" : 0 as AnyObject,
                             "showinfo" : 0 as AnyObject,
                             "modestbranding": 1 as AnyObject,
                             "playsinline" : 1 as AnyObject,
                             "autoplay" : 1 as AnyObject]
        let myVideoURL = URL(string: url)
        player.loadVideoURL(myVideoURL!)
        
    }
    
    fileprivate func addShareBarButton() {
        self.navigationController!.navigationBar.tintColor = UIColor.gray
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Share"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongWithVideoViewController.shareActions))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func fullScreen() {
        performSegue(withIdentifier: "fullScreen", sender: self)
    }
    
    @IBAction func playOrStop(_ sender: Any) {
        setAction()
    }
    
    func setAction() {
        if hadYoutubeLink {
            if play {
                play = false
                actionButton.isHidden = true
                floatingbutton.isHidden = false
                player.isHidden = true
                playerHeight.constant = 0
                player.stop()
            } else {
                play = true
                actionButton.setImage(UIImage(named: "stop"), for: UIControlState())
                floatingbutton.isHidden = true
                actionButton.isHidden = false
                player.isHidden = false
                playerHeight.constant = 250
                player.play()
            }
        } else {
            presentationData.setupScreen()
            presentation(IndexPath(row: 0, section: 0))
        }
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
            fullScreenController.authorName = authorName
        }
    }
    
    
    
    
    class CustomProvider : UIActivityItemProvider {
        var messagerMessage : String!
        var emailMessage : String!
        var otherMessage : String!
        
        init(placeholderItem: AnyObject, messagerMessage : String, emailMessage : String, otherMessage : String) {
            super.init(placeholderItem: placeholderItem)
            self.messagerMessage = messagerMessage
            self.emailMessage = emailMessage
            self.otherMessage = otherMessage
        }
        
        override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
            if activityType == UIActivityType.message {
                return messagerMessage as AnyObject?
            } else if activityType == UIActivityType.mail {
                return emailMessage as AnyObject?
            } else if activityType == UIActivityType.postToTwitter {
                return NSLocalizedString(messagerMessage, comment: "comment")
            } else {
                return otherMessage
            }
        }
    }
    
    func getObjectToShare() -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "<html><body>"))
        objectString.append(NSAttributedString(string: "<h1><a href=\"https://itunes.apple.com/us/app/tamil-christian-worship-songs/id1066174826?mt=8\">Tamil Christian Worship Songs</a></h1>"))
        
        if isLanguageTamil && !selectedSong.i18nTitle.isEmpty {
            objectString.append(NSAttributedString(string: "<h2>\(selectedSong.i18nTitle)</h2>"))
        } else {
            objectString.append(NSAttributedString(string: "<h2>\(songName)</h2>"))
        }
        for verseOrder in verseOrderList {
            objectString.append(getObject(verseOrder: verseOrder as! String))
        }
        objectString.append(NSAttributedString(string: "<br/>"))
        objectString.append(NSAttributedString(string: "</body></html>"))
        return objectString
    }
    
    func getObject(verseOrder: String) -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        let key: String = verseOrder.lowercased()
        let dataText: String? = listDataDictionary[key] as? String
        let texts = parseString(text: dataText!)
        print("verseOrder \(verseOrder)")
        for text in texts {
            objectString.append(NSAttributedString(string: text))
            objectString.append(NSAttributedString(string: "<br/>"))
        }
        objectString.append(NSAttributedString(string: "<br/>"))
        return objectString
    }
    
    func parseString(text: String) -> [String] {
        let attributeText = customTextSettingService.getAttributedString(text as NSString)
        //    let parsedText = attributeText.string.replacingOccurrences(of: "\n", with: "\n{n}")
        return attributeText.string.components(separatedBy: "\n")
    }
    
    func getMessageToShare() -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "Tamil Christian Worship Songs\n\n"))
        if isLanguageTamil && !selectedSong.i18nTitle.isEmpty{
            objectString.append(NSAttributedString(string: "\n\(selectedSong.i18nTitle)\n\n"))
        } else {
            objectString.append(NSAttributedString(string: "\n\(songName)\n\n"))
        }
        
        for verseOrder in verseOrderList {
            objectString.append(getMessage(verseOrder: verseOrder as! String))
        }
        objectString.append(NSAttributedString(string: "\n"))
        return objectString
    }
    
    func getMessage(verseOrder: String) ->  NSMutableAttributedString{
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        let key: String = (verseOrder).lowercased()
        let dataText: String? = listDataDictionary[key] as? String
        let texts = parseString(text: dataText!)
        print("verseOrder \(verseOrder)")
        for text in texts {
            objectString.append(NSAttributedString(string: text))
            objectString.append(NSAttributedString(string: "\n"))
        }
        objectString.append(NSAttributedString(string: "\n"))
        return objectString
    }
    
    func getAllCells() -> [UITableViewCell] {
        
        var cells = [UITableViewCell]()
        // assuming tableView is your self.tableView defined somewhere
        for i in 0...self.verseOrderList.count-1
        {
            let key: String = (verseOrderList[i] as! String).lowercased()
            let dataText: NSString? = listDataDictionary[key] as? NSString
            let cell = UITableViewCell()
            let fontSize = self.preferences.integer(forKey: "fontSize")
            cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize + 5))
            cell.textLabel!.numberOfLines = 0
            cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!);
            cells.append(cell)
        }
        return cells
    }
    
}

// MARK: - Table view data source
extension SongWithVideoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.verseOrderList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
        return cell
    }
}

extension SongWithVideoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nextButton.isHidden == false || previousButton.isHidden == false {
            presentation(indexPath)
        }
    }
}

extension SongWithVideoViewController: XMLParserDelegate {
    
    func setXmlParser() {
        element = ""
        attribues = NSDictionary()
        listDataDictionary = NSMutableDictionary()
        parsedVerseOrderList = NSMutableArray()
        verseOrderList = NSMutableArray()
        let lyrics: Data = songLyrics.data(using: String.Encoding.utf8.rawValue)!
        let parser = XMLParser(data: lyrics)
        parser.delegate = self
        parser.parse()
        if(verseOrderList.count < 1){
            print("parsedVerseOrderList:\(parsedVerseOrderList)")
            verseOrderList = parsedVerseOrderList
        }
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

// MARK: - Presentation action source
extension SongWithVideoViewController {
    
    fileprivate func setNextButton() {
        nextButton.layer.cornerRadius = nextButton.layer.frame.height / 2
        nextButton.clipsToBounds = true
        nextButton.isHidden = true
    }
    
    fileprivate func setPreviousButton() {
        previousButton.layer.cornerRadius = previousButton.layer.frame.height / 2
        previousButton.clipsToBounds = true
        previousButton.isHidden = true
    }
    
    @IBAction func tapOnPreviousButton(_ sender: Any) {
        var indexPath = IndexPath(row: 0, section: 0)
        if tableView.indexPathForSelectedRow != nil {
            indexPath = IndexPath(row: (tableView.indexPathForSelectedRow?.row)!, section: (tableView.indexPathForSelectedRow?.section)! - 1)
        }
        presentation(indexPath)
    }
    
    @IBAction func tapOnNextButton(_ sender: Any) {
        var indexPath = IndexPath(row: 0, section: 0)
        if tableView.indexPathForSelectedRow != nil {
            indexPath = IndexPath(row: (tableView.indexPathForSelectedRow?.row)!, section: (tableView.indexPathForSelectedRow?.section)! + 1)
        }
        presentation(indexPath)
    }
    
    func presentation(_ indexPath: IndexPath) {
        if UIScreen.screens.count > 1 {
            self.preferences.setValue(authorName, forKeyPath: "presentationAuthor")
            self.preferences.setValue(songName, forKeyPath: "presentationSongName")
            self.preferences.synchronize()
            tableView.allowsSelection = true
            presentVerse(indexPath)
            actionButton.isHidden = true
            floatingbutton.isHidden = true
        } else {
            let alertController = self.getAlertController(message: "message.presentSong".localized)
            alertController.addAction(self.getCancelAction())
            self.present(alertController, animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
    }
    
    func presentVerse(_ indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        let key = (verseOrderList[(indexPath as NSIndexPath).section] as! String).lowercased()
        let dataText: NSString? = listDataDictionary[key] as? NSString
        self.preferences.setValue(dataText, forKey: "presentationLyrics")
        let slideNumber = String(indexPath.section + 1) + " of " + String(tableView.numberOfSections)
        self.preferences.setValue(slideNumber, forKeyPath: "presentationSlide")
        self.preferences.setValue(indexPath.section, forKeyPath: "presentationSlideNumber")
        self.preferences.synchronize()
        self.presentationData.updateScreen()
        previousButton.isHidden = indexPath.section <= 0
        nextButton.isHidden = indexPath.section >= tableView.numberOfSections - 1
    }
    
}

extension SongWithVideoViewController: SongSelectionDelegate {
    
    internal func songSelected(_ newSong: Songs!)
    {
        selectedSong = newSong
        
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray
    {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
}

extension SongWithVideoViewController: UIGestureRecognizerDelegate {
    
    fileprivate func addLongPressGestureRecognizer() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SongWithVideoViewController.onCellViewLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    internal func onCellViewLongPress(_ longPressGesture: UILongPressGestureRecognizer) {
        
        if  actionButton.isHidden == false  || floatingbutton.isHidden == false {
            let pressingPoint = longPressGesture.location(in: self.tableView)
            if longPressGesture.state == UIGestureRecognizerState.began {
                tableView.allowsSelection = true
                UIView.transition(with: self.tableView, duration: 00.35, options: [], animations: { () -> Void in
                    let indexPath = self.tableView.indexPathForRow(at: pressingPoint)
                    if indexPath != nil {
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                        let text = self.tableView.cellForRow(at: indexPath!)?.textLabel?.attributedText
                        self.shareLyrics(lyrics: text as! NSMutableAttributedString, indexPath: indexPath!)
                    }
                }, completion: nil)
            }
        }
    }
    
    func shareLyrics(lyrics: NSMutableAttributedString, indexPath: IndexPath) {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: "<html><body>"))
        objectString.append(NSAttributedString(string: "<h1><a href=\"http://apple.co/2mJwePJ\">Tamil Christian Worship Songs</a></h1>"))
        objectString.append(getObject(verseOrder: verseOrderList[indexPath.section] as! String))
        objectString.append(NSAttributedString(string: "</body></html>"))
        
        let messageString = getMessage(verseOrder: verseOrderList[indexPath.section] as! String)
        messageString.append(NSAttributedString(string: "\n\n"))
        messageString.append(NSAttributedString(string: "  http://apple.co/2mJwePJ"))
        
        let otherString = objectString
        otherString.append(NSAttributedString(string: "http://apple.co/2mJwePJ"))
        
        let activityItem = CustomProvider(placeholderItem: "Default" as AnyObject, messagerMessage: messageString.string, emailMessage: objectString.string, otherMessage: otherString.string)
        let objectsToShare = [activityItem]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let popUpView = self.tableView.cellForRow(at: indexPath)?.contentView
        activityVC.popoverPresentationController?.sourceView = popUpView
        activityVC.popoverPresentationController?.sourceRect = (popUpView?.bounds)!
        activityVC.setValue("Tamil Christian Worship Songs " + songName, forKey: "Subject")
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.postToFacebook, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
        self.present(activityVC, animated: true, completion: { () -> Void in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.allowsSelection = false
        })
    }
    
}
//MARK: Share song in social media
extension SongWithVideoViewController {
    
    func shareActions() {
        let shareActions = UIAlertController(title: "choose_options".localized, message: "", preferredStyle: .actionSheet)
        shareActions.addAction(getShareAction())
        shareActions.addAction(getShareAsPdfAction())
        shareActions.addAction(getCancelnSheetAction())
        self.present(shareActions, animated: true, completion: nil)
    }
    
    func getShareAction() -> UIAlertAction {
        return UIAlertAction(title: "share_song_title".localized, style: .default, handler: { _ in
            self.shareInSocialMedia()
        })
    }
    
    func getShareAsPdfAction() -> UIAlertAction {
        return UIAlertAction(title: "share_as_pdf".localized, style: .default, handler: { _ in
            let pdf = SimplePDF(pdfTitle: "", authorName: "", fileName: self.getSongTitle() + self.pdfExtension)
            self.addDocumentContent(pdf)
            let tmpPDFPath = pdf.writePDFWithoutTableOfContents()
            let pdfURL = URL(fileURLWithPath: tmpPDFPath)
            self.showActivityViewController([pdfURL])
        })
    }
    
    fileprivate func getSongTitle() -> String {
        if isLanguageTamil && !selectedSong.i18nTitle.isEmpty{
            return selectedSong.i18nTitle
        } else {
            return songName
        }
    }
    
    fileprivate func addDocumentContent(_ pdf: SimplePDF) {
        pdf.addH2(self.getSongTitle())
        pdf.addBodyText(self.getMessageToShare().string)
    }
    
    func getCancelnSheetAction() -> UIAlertAction {
        return UIAlertAction(title: "cancel".localized, style: .cancel, handler: { _ in
            
        })
    }
    
    func shareInSocialMedia() {
        let emailMessage = getObjectToShare()
        let messagerMessage = getMessageToShare()
        let otherMessage = emailMessage
        otherMessage.append(NSAttributedString(string: "http://apple.co/2mJwePJ"))
        
        let firstActivityItem = CustomProvider(placeholderItem: "Default" as AnyObject, messagerMessage: messagerMessage.string, emailMessage: emailMessage.string, otherMessage: otherMessage.string)
        showActivityViewController([firstActivityItem])
        
    }
    
    func showActivityViewController(_ objectToShare: [Any]) {
        let activityVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        activityVC.setValue("Tamil Christian Worship Songs " + songName, forKey: "Subject")
        activityVC.excludedActivityTypes = getExcludedActivityTypes()
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func getExcludedActivityTypes() -> [UIActivityType] {
        return [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.postToFacebook, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
    }
}

