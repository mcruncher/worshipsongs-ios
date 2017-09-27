//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit

class ManageFavoritesController: UIViewController {

    fileprivate let preferences = UserDefaults.standard
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var songTitle = ""
    var isLanguageTamil = false
    
    var suggestedFavorites = [String]()
    var song: Songs!
    fileprivate var screenYPostion = CGFloat()
    var favoriteList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTitle = song.title
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        if isLanguageTamil && !song.i18nTitle.isEmpty {
            songTitle = song.i18nTitle
        }
        songLabel.text = songTitle
        self.navigationItem.title = "addToFavorites".localized
        self.tableView.tableFooterView = getTableFooterView()
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 0))
        return footerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favoriteList = (preferences.array(forKey: "favorites") as? [String])!
        tableView.isHidden = favoriteList.count <= 0
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createFav(_ sender: Any) {
        performSegue(withIdentifier: "addFav", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "addFav") {
            let addFavoritesController = segue.destination as! AddFavoriteViewController
            addFavoritesController.song = song
            addFavoritesController.songTitle = songTitle
        }
    }
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
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
            self.close()
        })
    }

}

extension ManageFavoritesController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favorite", for: indexPath)
        cell.textLabel?.text = favoriteList[indexPath.row]
        let decoded  = self.preferences.object(forKey: favoriteList[indexPath.row]) as! Data
        let favSongs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
        if favSongs.count > 0 {
            cell.detailTextLabel?.text =  String(favSongs.count) + " Songs"
        } else {
            cell.detailTextLabel?.text = "0 Songs"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var favSongs = [FavoritesSongsWithOrder]()
        var favSongOrderNumber = 0
        if self.preferences.data(forKey: favoriteList[indexPath.row]) != nil {
            let decoded  = self.preferences.object(forKey: favoriteList[indexPath.row]) as! Data
            favSongs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
            if favSongs.count > 0 {
                favSongOrderNumber = (favSongs.last?.orderNo)! + 1
            }
        }
        let newFavSong = FavoritesSongsWithOrder(orderNo: favSongOrderNumber, songName: song.title, songListName: favoriteList[indexPath.row])
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
            self.preferences.set(encodedData, forKey: favoriteList[indexPath.row])
            self.preferences.synchronize()
            let message = NSString(format: "added.success".localized as NSString, favoriteList[indexPath.row])
            self.present(self.confirmAlertController(message as String), animated: true, completion: nil)
        }
    }
}
