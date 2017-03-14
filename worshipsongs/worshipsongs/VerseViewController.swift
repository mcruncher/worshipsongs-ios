//
// author: Madasamy
// version: 1.8.0
//
import UIKit

class VerseViewController: UIViewController {
    
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    fileprivate var databaseHelper = DatabaseHelper()
    
    var song = Songs()
    
    fileprivate var element:String!
    
    fileprivate var attribues : NSDictionary = NSDictionary()
    fileprivate var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
    fileprivate var parsedVerseOrderList: NSMutableArray = NSMutableArray()
    fileprivate var verseOrderList: NSMutableArray = NSMutableArray()
    
    fileprivate let preferences = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOnSelectNotification()
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setOnSelectNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(VerseViewController.onSelectSong(_:)), name: NSNotification.Name(rawValue: CommonConstansts.OnSelectSongKey), object: nil)
    }
    
    func onSelectSong(_ nsNotification: NSNotification) {
        element = ""
        attribues = NSDictionary()
        listDataDictionary = NSMutableDictionary()
        parsedVerseOrderList = NSMutableArray()
        verseOrderList = NSMutableArray()
        let song = (nsNotification as NSNotification).userInfo![CommonConstansts.songKey]
        if song != nil {
           self.song = song as! Songs
        }
        setXmlParser()
        self.tableView.reloadData()
    }
    
    func setXmlParser() {
        
        let lyrics: Data = song.lyrics.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let parser = XMLParser(data: lyrics)
        parser.delegate = self
        parser.parse()
        if(verseOrderList.count < 1){
            print("parsedVerseOrderList:\(parsedVerseOrderList)")
            verseOrderList = parsedVerseOrderList
        }
    }
    
}

extension VerseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

extension VerseViewController: UITableViewDataSource {
    
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
        //        let fontColor = self.preferences.string(forKey: "englishFontColor")!
        //        cell.textLabel!.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: fontColor)!)
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.attributedText = customTextSettingService.getAttributedString(dataText!);
        print("cell\(cell.textLabel!.attributedText )")
        return cell
    }
}

extension VerseViewController:  XMLParserDelegate {
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // text = string
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
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        print("element:\(element)")
        attribues = attributeDict as NSDictionary
        print("attribues:\(attribues)")
    }
}

