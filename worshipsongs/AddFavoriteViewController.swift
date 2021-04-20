//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit

class AddFavoriteViewController: UIViewController {
    @IBOutlet weak var favoriteName: UITextField!
    fileprivate let preferences = UserDefaults.standard
    var songTitle = ""
    var isLanguageTamil = false
    
    var suggestedFavorites = [String]()
    var song: Song!
    fileprivate var screenYPostion = CGFloat()
    var favoriteList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
       self.navigationItem.title = "newFavorite".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func valueChanged(_ sender: Any) {
       self.navigationItem.rightBarButtonItem?.isEnabled = !(favoriteName.text?.isEmpty)!
    }
    
    @IBAction func createFav(_ sender: Any) {
        favoriteName.resignFirstResponder()
        var favoriteKey = CommonConstansts.favorite
        if !(favoriteName.text?.isEmpty)! {
            favoriteKey = favoriteName.text!
        }
        favoriteList = (preferences.array(forKey: CommonConstansts.favorites) as? [String])!
        if !favoriteList.contains(favoriteKey) {
            favoriteList.append(favoriteKey)
            self.preferences.set(favoriteList, forKey: CommonConstansts.favorites)
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
                self.present(self.confirmAlertController("message.exist".localized), animated: true, completion: nil)
            }
        }
        if !isSongExist {
            favSongs.append(newFavSong)
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favSongs)
            self.preferences.set(encodedData, forKey: favoriteKey)
            self.preferences.synchronize()
            let message = NSString(format: "added.success".localized as NSString, favoriteKey)
            self.present(self.confirmAlertController(message as String), animated: true, completion: nil)
            
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
       _ = self.navigationController?.popViewController(animated: false)
    }
    
    fileprivate func confirmAlertController(_ message: String) -> UIAlertController
    {
        let confirmationAlertController =
            UIAlertController(title: songTitle,
                              message: message, preferredStyle: UIAlertControllerStyle.alert)
        confirmationAlertController.addAction(self.getCancelAction(title: "ok"))
        return confirmationAlertController
    }
    
    fileprivate func getCancelAction(title: String) -> UIAlertAction
    {
        return UIAlertAction(title: title.localized, style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
            _ = self.navigationController?.popToRootViewController(animated: false)
        })
    }

}
