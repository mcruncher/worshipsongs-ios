//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit

class ManageFavoritesController: UIViewController {

    fileprivate let preferences = UserDefaults.standard
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteName: AutoCompleteTextField!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    var songTitle = ""
    var isLanguageTamil = false
    
    var suggestedFavorites = [String]()
    var song: Songs!
    fileprivate var screenYPostion = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "addToFavorites".localized
        songTitle = song.title
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        if isLanguageTamil && !song.i18nTitle.isEmpty {
            songTitle = song.i18nTitle
        }
        songLabel.text = songTitle
        setFavoriteAutoCompleteFieldProperties()
        setFavoriteTextFieldOnChangeBehaviour()
        adjustScreenPosition()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createFav(_ sender: Any) {
        var favoriteKey = "favorite"
        if !(favoriteName.text?.isEmpty)! {
            favoriteKey = favoriteName.text!
        }
        var favoriteList = (preferences.array(forKey: "favorites") as? [String])!
        if !favoriteList.contains(favoriteKey) {
            favoriteList.append(favoriteKey)
            self.preferences.set(favoriteList, forKey: "favorites")
            self.preferences.synchronize()
        }
        
        var favSongs = [FavoritesSongsWithOrder]()
        var favSongOrderNumber = 0
        if self.preferences.data(forKey: favoriteKey) != nil {
            let decoded  = self.preferences.object(forKey: favoriteKey) as! Data
            favSongs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
            if favSongs.count > 0 {
                favSongOrderNumber = (favSongs.last?.orderNo)! + 1
            }
        }
        let newFavSong = FavoritesSongsWithOrder(orderNo: favSongOrderNumber, songName: song.title, songListName: favoriteKey)
        var isSongExist = false
        for favSong in favSongs {
            if favSong.songName == newFavSong.songName {
                isSongExist = true
                self.present(self.getExistsAlertController(), animated: true, completion: nil)
            }
        }
        if !isSongExist {
            favSongs.append(newFavSong)
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favSongs)
            self.preferences.set(encodedData, forKey: favoriteKey)
            self.preferences.synchronize()
            close()
        }
    }

    @IBAction func close(_ sender: Any) {
        close()
    }
    
    fileprivate func setFavoriteAutoCompleteFieldProperties() {
        favoriteName.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        favoriteName.autoCompleteStrings = suggestedFavorites
        favoriteName.hidesWhenSelected = true
        favoriteName.hidesWhenEmpty = true
        favoriteName.autoCompleteCellHeight = 35.0
        favoriteName.maximumAutoCompleteCount = 5
        favoriteName.autoCompleteTableHeight = 175.0
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.white
        attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 14.0)
        attributes[NSBackgroundColorAttributeName] = UIColor.gray
        favoriteName.autoCompleteAttributes = attributes
    }
    
    fileprivate func setFavoriteTextFieldOnChangeBehaviour() {
        let favoriteList = (preferences.array(forKey: "favorites") as? [String])!
        favoriteName.onTextChange = { text in
            if !text.isEmpty {
                self.suggestedFavorites.removeAll()
                for favorite in favoriteList {
                    if favorite.lowercased().range(of: text, options: [.anchored, .caseInsensitive]) != nil {
                        self.suggestedFavorites.append(favorite)
                    }
                }
                self.favoriteName.autoCompleteStrings = self.suggestedFavorites
                if self.suggestedFavorites.count > 0 {
                    self.favoriteName.autoCompleteTableHeight =
                        self.suggestedFavorites.count > 3 ? 108.0 :
                        CGFloat(self.suggestedFavorites.count) * 36.0
                    self.contentHeight.constant = 280
                } else {
                    self.favoriteName.autoCompleteTableHeight = 0
                    self.contentHeight.constant = 200
                }
            } else {
                self.favoriteName.autoCompleteTableHeight = 0
                self.contentHeight.constant = 200
            }
        }
        self.favoriteName.onSelect = { text, indexpath in
            self.suggestedFavorites.removeAll()
            _ = self.favoriteName.resignFirstResponder()
            self.contentHeight.constant = 200
            }
    }
    
    func close() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func adjustScreenPosition()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ManageFavoritesController.showKeyboard(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ManageFavoritesController.hideKeyboard(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        self.screenYPostion = self.view.frame.origin.y;
    }
    
    func showKeyboard(_ sender: Notification)
    {
        if ( self.screenYPostion ==  self.view.frame.origin.y && self.view.frame.height <= 500) {
            self.view.frame.origin.y -= 105
        } else if ( self.screenYPostion ==  self.view.frame.origin.y && self.view.frame.height <= 570) {
            self.view.frame.origin.y -= 30
        }
    }
    
    func hideKeyboard(_ sender: Notification)
    {
        if ( self.screenYPostion-105  ==  self.view.frame.origin.y) {
            self.view.frame.origin.y += 105
        } else if ( self.screenYPostion-30  ==  self.view.frame.origin.y) {
            self.view.frame.origin.y += 30
        }
    }
    
    fileprivate func getExistsAlertController() -> UIAlertController
    {
        let confirmationAlertController =
            UIAlertController(title: songTitle,
                              message: "message.exist".localized, preferredStyle: UIAlertControllerStyle.alert)
        confirmationAlertController.addAction(self.getCancelAction(title: "ok"))
        return confirmationAlertController
    }
    
    fileprivate func getCancelAction(title: String) -> UIAlertAction
    {
        return UIAlertAction(title: title.localized, style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
            self.close()
        })
    }

}
