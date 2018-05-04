//
// author: Madasamy, Vignesh Palanisamy
// version: 1.0.0
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    fileprivate var filteredSongModel = [FavoritesSong]()
    fileprivate var isLanguageTamil = true
    var songModel = [FavoritesSong]()
    var songOrder = [Int]()
    var songTitles = [String]()
    var databaseHelper = DatabaseHelper()
    var refresh = UIRefreshControl()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    var comment = ""
    var hideDragAndDrop = false
    fileprivate let preferences = UserDefaults.standard
    var searchBar: UISearchBar!
    var authorName = ""
    var favorite = "favorite"
    
    var songTabBarController: SongsTabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShareBarButton()
        self.tableView.tableFooterView = getTableFooterView()
        updateModel()
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(FavoritesTableViewController.longPressGestureRecognized))
        tableView.addGestureRecognizer(longpress)
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        if !hideDragAndDrop {
            let longPress = gestureRecognizer as! UILongPressGestureRecognizer
            let state = longPress.state
            let locationInView = longPress.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: locationInView)
            
            struct My {
                static var cellSnapshot : UIView? = nil
            }
            struct Path {
                static var initialIndexPath : NSIndexPath? = nil
            }
            switch state {
            case UIGestureRecognizerState.began:
                if indexPath != nil {
                    Path.initialIndexPath = indexPath as NSIndexPath?
                    let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                    My.cellSnapshot  = snapshopOfCell(inputView: cell!)
                    var center = cell?.center
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.alpha = 0.0
                    tableView.addSubview(My.cellSnapshot!)
                    
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        center?.y = locationInView.y
                        My.cellSnapshot!.center = center!
                        My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        My.cellSnapshot!.alpha = 0.98
                        cell?.alpha = 0.0
                        
                    }, completion: { (finished) -> Void in
                        if finished {
                            cell?.isHidden = true
                        }
                    })
                }
                
            case UIGestureRecognizerState.changed:
                if indexPath != nil && Path.initialIndexPath != nil{
                    var center = My.cellSnapshot!.center
                    center.y = locationInView.y
                    My.cellSnapshot!.center = center
                    if indexPath != Path.initialIndexPath as IndexPath? {
                        tableView.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                        Path.initialIndexPath = indexPath as NSIndexPath?
                    }
                }
                
            default:
                if Path.initialIndexPath != nil {
                    let cell = tableView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        My.cellSnapshot!.center = (cell?.center)!
                        My.cellSnapshot!.transform = CGAffineTransform.identity
                        My.cellSnapshot!.alpha = 0.0
                        cell?.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                        }
                    })
                    updateSongOrder()
                }
            }
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func updateSongOrder() {
        var newSongOrder = [FavoritesSongsWithOrder]()
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! TitleTableViewCell
            let favSong = FavoritesSongsWithOrder(orderNo: i, songName: cell.songTitle.text!, songListName: favorite)
            newSongOrder.append(favSong)
        }
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newSongOrder)
        self.preferences.set(encodedData, forKey: favorite)
        self.preferences.synchronize()
        updateModel()
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 2))
        footerview.backgroundColor = UIColor.groupTableViewBackground
        return footerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isLanguageTamil = preferences.string(forKey: CommonConstansts.language) == CommonConstansts.tamil
        self.navigationItem.title = favorite
    }
    
    func updateModel() {
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "refresh".localized)
        refresh.addTarget(self, action: #selector(FavoritesTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        refresh(self)
    }
    
    private func setDefaultSelectedSong() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongModel.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TitleTableViewCell
        if isLanguageTamil && !filteredSongModel[(indexPath as NSIndexPath).row].songs.i18nTitle.isEmpty {
            cell.title.text = filteredSongModel[(indexPath as NSIndexPath).row].songs.i18nTitle
        } else {
            cell.title.text = filteredSongModel[(indexPath as NSIndexPath).row].songTitle
        }
        cell.songTitle.text = filteredSongModel[(indexPath as NSIndexPath).row].songTitle
        let activeSong = preferences.string(forKey: "presentationSongName")
        if cell.title.text == activeSong {
            cell.title.textColor = UIColor.cruncherBlue()
        } else {
            cell.title.textColor = UIColor.black
        }
        if filteredSongModel[(indexPath as NSIndexPath).row].songs.id != "" && !filteredSongModel[(indexPath as NSIndexPath).row].songs.mediaUrl.isEmpty {
            cell.playImage.isHidden = false
        } else {
            cell.playImage.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        onSelectSong(indexPath.row)
    }
    
    func onSelectSong(_ row: Int) {
        let selectedSong = filteredSongModel[row].songs
        if selectedSong.id != "" {
            songTabBarController?.songdelegate?.songSelected(selectedSong)
            if let detailViewController = songTabBarController?.songdelegate as? SongWithVideoViewController {
                splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
            }
        } else {
            self.present(self.getNonExistsAlertController(filteredSongModel[row].songTitle), animated: true, completion: nil)
        }
    }
    
    
    fileprivate func getNonExistsAlertController(_ songName: String) -> UIAlertController {
        let confirmationAlertController = UIAlertController(title: songName, message: "message.not.exist".localized, preferredStyle: UIAlertControllerStyle.alert)
        confirmationAlertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertActionStyle.default, handler: nil))
        return confirmationAlertController
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray
    {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "songsWithVideo") {
            let songsTableViewController = segue.destination as! SongWithVideoViewController
            songsTableViewController.verseOrder = verseList
            songsTableViewController.songLyrics = songLyrics
            songsTableViewController.songName = songName
            songsTableViewController.comment = comment
            songsTableViewController.authorName = authorName
        }
    }
    
    @objc(tableView:editActionsForRowAtIndexPath:) override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = getTableViewRowAction(indexPath)
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    fileprivate func getTableViewRowAction(_ indexPath: IndexPath) -> UITableViewRowAction {
        return UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Remove") { (action, indexPath) -> Void in
            self.isEditing = false
            self.present(self.getConfirmationAlertController(indexPath), animated: true, completion: nil)
        }
    }
    
    fileprivate func getConfirmationAlertController(_ indexPath: IndexPath) -> UIAlertController {
        let confirmationAlertController = self.getDeleteController(indexPath)
        confirmationAlertController.addAction(self.getDeleteAction(indexPath))
        confirmationAlertController.addAction(self.getCancelAction(indexPath))
        return confirmationAlertController
    }
    
    fileprivate func getDeleteController(_ indexPath: IndexPath) -> UIAlertController {
        return UIAlertController(title: "remove".localized, message: "message.remove".localized, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    fileprivate func getDeleteAction(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            let decoded  = self.preferences.object(forKey: self.favorite) as! Data
            var newSongOrder = [FavoritesSongsWithOrder]()
            let favoritesSongsWithOrders = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
            let cell = self.tableView.cellForRow(at: indexPath) as! TitleTableViewCell
            for favoritesSongsWithOrder in favoritesSongsWithOrders {
                if favoritesSongsWithOrder.songName != cell.title.text {
                    newSongOrder.append(favoritesSongsWithOrder)
                }
            }
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newSongOrder)
            self.preferences.set(encodedData, forKey: self.favorite)
            self.preferences.synchronize()
            self.refresh(self)
        })
    }
    
    fileprivate func getCancelAction(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "No", style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableViewRowAnimation.automatic)
        })
    }
    
    @objc func refresh(_ sender:AnyObject)
    {
        if self.preferences.data(forKey: favorite) != nil {
            let decoded  = self.preferences.object(forKey: favorite) as! Data
            let favoritesSongsWithOrders = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
            var favoritesSongs = [FavoritesSong]()
            for favoritesSongsWithOrder in favoritesSongsWithOrders {
                let songs = databaseHelper.getSongsModelTitles([favoritesSongsWithOrder.songName])
                if songs.count > 0 {
                    favoritesSongs.append(FavoritesSong(songTitle:favoritesSongsWithOrder.songName, songs: songs[0], favoritesSongsWithOrder: favoritesSongsWithOrder))
                } else {
                    favoritesSongs.append(FavoritesSong(songTitle:favoritesSongsWithOrder.songName, songs: Songs(), favoritesSongsWithOrder: favoritesSongsWithOrder))
                }
            }
            songModel = favoritesSongs
            songModel.sort(by: { (fav1, fav2) -> Bool in
                fav1.favoritesSongsWithOrder.orderNo < fav2.favoritesSongsWithOrder.orderNo
            })
            filteredSongModel = songModel
        }
        self.tableView.reloadData()
        self.refresh.endRefreshing()
        hideDragAndDrop = false
    }
    
    fileprivate func addShareBarButton() {
        self.navigationController!.navigationBar.tintColor = UIColor.gray
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Share"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(FavoritesTableViewController.shareInSocialMedia))
        navigationItem.rightBarButtonItem = doneButton
    }
}

extension FavoritesTableViewController {
    @objc func shareInSocialMedia() {
        let messagerMessage = getMessageToShare()
        messagerMessage.append(NSAttributedString(string: "https://goo.gl/k1QG4J"))
        showActivityViewController([messagerMessage])
    }
    
    func getMessageToShare() -> NSMutableAttributedString {
        let objectString: NSMutableAttributedString = NSMutableAttributedString()
        objectString.append(NSAttributedString(string: favorite + "\n"))
        var number = 0
        for songModel in filteredSongModel {
            number = number + 1
            if !songModel.songs.i18nTitle.isEmpty {
                objectString.append(NSAttributedString(string: "\n\(number). \(songModel.songs.i18nTitle)\n"))
                objectString.append(NSAttributedString(string: "\(songModel.songs.title)\n"))
            } else {
                objectString.append(NSAttributedString(string: "\n\(number). \(songModel.songs.title)\n"))
            }
        }
        objectString.append(NSAttributedString(string: "\n"))
        return objectString
    }
    
    func showActivityViewController(_ objectToShare: [Any]) {
        let activityVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        activityVC.setValue("Tamil Christian Worship Songs " + favorite, forKey: "Subject")
        activityVC.excludedActivityTypes = getExcludedActivityTypes()
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func getExcludedActivityTypes() -> [UIActivityType] {
        return [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.postToFacebook, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
    }
}

