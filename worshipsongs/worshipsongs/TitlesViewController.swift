//
// author: Madasamy, Vignesh Palanisamy
// version: 1.0.0
//

import UIKit

class TitlesViewController: UITableViewController {
    
    fileprivate let preferences = UserDefaults.standard
    fileprivate var songModel = [Songs]()
    fileprivate var filteredSongModel = [Songs]()
    fileprivate var databaseHelper = DatabaseHelper()
    fileprivate var searchBar: UISearchBar!
    fileprivate var refresh = UIRefreshControl()
    fileprivate var songTabBarController: SongsTabBarViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(TitlesViewController.hideSearch), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        addRefreshControl()
        addSearchBar()
        addLongPressGestureRecognizer()
        initSetup()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        addSearchBar()
        initSetup()
    }
    
    func addRefreshControl()
    {
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(TitlesViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
    }
    
    func refresh(_ sender:AnyObject)
    {
        filteredSongModel = songModel
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    internal func onCellViewLongPress(_ longPressGesture: UILongPressGestureRecognizer)
    {
        let pressingPoint = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: pressingPoint)
        if longPressGesture.state == UIGestureRecognizerState.began {
            self.present(self.getConfirmationAlertController(indexPath!), animated: true, completion: nil)
        }
    }
    
    fileprivate func getConfirmationAlertController(_ indexPath: IndexPath) -> UIAlertController
    {
        let confirmationAlertController = self.getMoveController(indexPath, message: "message.add")
        confirmationAlertController.addAction(self.getMoveAction(indexPath))
        confirmationAlertController.addAction(self.getCancelAction(indexPath, title: "no"))
        return confirmationAlertController
    }
    
    fileprivate func getMoveController(_ indexPath: IndexPath, message: String) -> UIAlertController
    {
        return UIAlertController(title: filteredSongModel[(indexPath as NSIndexPath).row].title, message: message.localized, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    fileprivate func getMoveAction(_ indexPath: IndexPath) -> UIAlertAction
    {
        return UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            let song = self.filteredSongModel[indexPath.row]
            var favSongs = [FavoritesSongsWithOrder]()
            var favSongOrderNumber = 0
            if self.preferences.data(forKey: "favorite") != nil {
                let decoded  = self.preferences.object(forKey: "favorite") as! Data
                favSongs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
                if favSongs.count > 0 {
                    favSongOrderNumber = (favSongs.last?.orderNo)! + 1
                }
            }
            let newFavSong = FavoritesSongsWithOrder(orderNo: favSongOrderNumber, songName: song.title, songListName: "favorite")
            var isSongExist = false
            for favSong in favSongs {
                if favSong.songName == newFavSong.songName {
                    isSongExist = true
                    self.present(self.getExistsAlertController(indexPath), animated: true, completion: nil)
                }
            }
            if !isSongExist {
                favSongs.append(newFavSong)
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: favSongs)
                self.preferences.set(encodedData, forKey: "favorite")
                self.preferences.synchronize()
            }
        })
    }
    
    fileprivate func getExistsAlertController(_ indexPath: IndexPath) -> UIAlertController
    {
        let confirmationAlertController = self.getMoveController(indexPath, message: "message.exist")
        confirmationAlertController.addAction(self.getCancelAction(indexPath, title: "ok"))
        return confirmationAlertController
    }
    
    fileprivate func getCancelAction(_ indexPath: IndexPath, title: String) -> UIAlertAction
    {
        return UIAlertAction(title: title.localized, style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableViewRowAnimation.automatic)
        })
    }
    
    private func initSetup()
    {
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "songs".localized
        songModel = databaseHelper.getSongModel()
        filteredSongModel = songModel
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Table view data source
extension TitlesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TitleTableViewCell
        cell.title.text = filteredSongModel[(indexPath as NSIndexPath).row].title
        let activeSong = preferences.string(forKey: "presentationSongName")
        if cell.title.text == activeSong && UIScreen.screens.count > 1 {
            cell.title.textColor = UIColor.cruncherBlue()
        } else {
            cell.title.textColor = UIColor.black
        }
        if filteredSongModel[(indexPath as NSIndexPath).row].comment != nil && filteredSongModel[(indexPath as NSIndexPath).row].comment.contains("youtube") {
            cell.playImage.isHidden = false
        } else {
            cell.playImage.isHidden = true
        }
        return cell
    }
    
}

// MARK: - Table view delegate
extension TitlesViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectSong(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func onSelectSong(_ row: Int) {
        let selectedSong = filteredSongModel[row]
        songTabBarController?.songdelegate?.songSelected(selectedSong)
        hideSearchBar()
        if let detailViewController = songTabBarController?.songdelegate as? SongWithVideoViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }
    
}

extension TitlesViewController: UIGestureRecognizerDelegate {
    
    fileprivate func addLongPressGestureRecognizer() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TitlesViewController.onCellViewLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
}

extension TitlesViewController: UISearchBarDelegate {
    
    fileprivate func addSearchBar() {
        // Search bar
        let searchBarFrame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: 44);
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self;
        searchBar.showsCancelButton = true;
        searchBar.tintColor = UIColor.gray
        self.addSearchBarButton()
    }
    
    fileprivate func addSearchBarButton() {
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(TitlesViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func searchButtonItemClicked(_ sender:UIBarButtonItem) {
        self.tabBarController?.navigationItem.titleView = searchBar;
        let songTabBarController = self.tabBarController as! SongsTabBarViewController
        songTabBarController.searchBarDisplay = true
        let searchBy = self.preferences.string(forKey: "searchBy")
        self.tabBarController?.navigationItem.leftBarButtonItem?.image = UIImage(named: searchBy!)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar)
        self.tableView.reloadData()
    }
    
    fileprivate func filterContentForSearchText(_ searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = songModel
        if (searchText?.characters.count)! > 0 {
            data = self.songModel.filter({( song: Songs) -> Bool in
                if (self.preferences.string(forKey: "searchBy")?.equalsIgnoreCase("searchByTitle"))! {
                    let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                } else {
                    let stringMatch = (song.lyrics as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                }
            })
        }
        self.filteredSongModel = data
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        filteredSongModel = songModel
        tableView.reloadData()
    }
    
    @objc fileprivate func hideSearch() {
        if DeviceUtils.isIpad() {
            hideSearchBar()
        }
    }
    
    fileprivate func hideSearchBar() {
        self.tabBarController?.navigationItem.titleView = nil
        let songTabBarController = self.tabBarController as! SongsTabBarViewController
        songTabBarController.searchBarDisplay = false
        songTabBarController.optionMenu.dismiss(animated: true, completion: nil)
        self.tabBarController?.navigationItem.leftBarButtonItem?.image = UIImage(named: "setting")
        self.searchBar.text = ""
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(TitlesViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
}
