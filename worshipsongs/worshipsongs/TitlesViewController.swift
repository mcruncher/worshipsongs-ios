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
    fileprivate var isLanguageTamil = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addRefreshControl()
        addSearchBar()
        addLongPressGestureRecognizer()
        initSetup()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !isLanguageSet() {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "language") as? LanguageSettingViewController
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        addSearchBar()
        initSetup()
    }
    
    func isLanguageSet() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("language")
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
        if indexPath != nil && longPressGesture.state == UIGestureRecognizerState.began {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "favorite") as? ManageFavoritesController
            viewController?.song = filteredSongModel[(indexPath?.row)!]
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
    }
    
    private func initSetup()
    {
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "songs".localized
        songModel = databaseHelper.getSongModel()
        filteredSongModel = songModel
        sortSongModel()
        tableView.reloadData()
    }
    
    func sortSongModel()
    {
        if isLanguageTamil {
            filteredSongModel = filteredSongModel.sorted(){ (a, b) -> Bool in
                if a.i18nTitle.isEmpty {
                    return false
                } else if b.i18nTitle.isEmpty {
                    return true
                } else {
                    return a.i18nTitle < b.i18nTitle
                }
            }
        } else {
            filteredSongModel = filteredSongModel.sorted(){ $0.title < $1.title }
        }
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
        if isLanguageTamil && !filteredSongModel[(indexPath as NSIndexPath).row].i18nTitle.isEmpty {
            cell.title.text = filteredSongModel[(indexPath as NSIndexPath).row].i18nTitle
        } else {
            cell.title.text = filteredSongModel[(indexPath as NSIndexPath).row].title
        }
        let activeSong = preferences.string(forKey: "presentationSongName")
        if cell.title.text == activeSong && UIScreen.screens.count > 1 {
            cell.title.textColor = UIColor.cruncherBlue()
        } else {
            cell.title.textColor = UIColor.black
        }
        if filteredSongModel[(indexPath as NSIndexPath).row].mediaUrl.isEmpty {
            cell.playImage.isHidden = true
        } else {
            cell.playImage.isHidden = false
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

extension TitlesViewController: UISearchBarDelegate, TitleOrContentBaseSearchDelegate {
    
    fileprivate func addSearchBar() {
        // Search bar
        let songTabBarController = self.tabBarController as! SongsTabBarViewController
        songTabBarController.searchDelegate = self
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
                    let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!) || (song.comment as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                } else {
                    let stringMatch = (song.lyrics as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                }
            })
        }
        self.filteredSongModel = data
        sortSongModel();
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        sortSongModel()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        filteredSongModel = songModel
        sortSongModel()
        tableView.reloadData()
    }
    
    func hideSearch() {
        if DeviceUtils.isIpad() {
            hideSearchBar()
            filteredSongModel = songModel
            sortSongModel()
            tableView.reloadData()
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
