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
    fileprivate var addToFav: Songs!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: .largeTitle)
            ]
        }
        addRefreshControl()
        addLongPressGestureRecognizer()
        initSetup()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !isLanguageSet() {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "language") as? LanguageSettingViewController
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
        if !isUserRateUs() {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "rateUs") as? RateUsViewController
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        initSetup()
    }
    
    func isLanguageSet() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("language")
    }
    
    func isUserRateUs() -> Bool {
        let rateUsDate = preferences.object(forKey: "rateUsDate") as? Date
        return rateUsDate! > Date()
    }
    
    func addRefreshControl()
    {
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(TitlesViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
    }
    
    @objc func refresh(_ sender:AnyObject)
    {
        filteredSongModel = songModel
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    @objc internal func onCellViewLongPress(_ longPressGesture: UILongPressGestureRecognizer)
    {
        let pressingPoint = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: pressingPoint)
        if indexPath != nil && longPressGesture.state == UIGestureRecognizerState.began {
            addToFav = filteredSongModel[(indexPath?.row)!]
            performSegue(withIdentifier: CommonConstansts.manageFav, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == CommonConstansts.manageFav) {
            let manageFavoritesController = segue.destination as! ManageFavoritesController
            manageFavoritesController.song = addToFav
        }
    }
    
    private func initSetup() {
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "songs".localized
        songTabBarController?.searchDelegate = self
        songTabBarController?.searchDelegate4S = self
        songModel = databaseHelper.getSongModel()
        filteredSongModel = songModel
        sortSongModel()
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
            cell.title.textColor = cell.titleTextColor
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
        songTabBarController?.closeSearchBar()
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

extension TitlesViewController : SearchDelegateIOS11 {
    func hideSearch() {
        if DeviceUtils.isIpad() {
            songTabBarController?.closeSearchBar()
            cancelSearch()
        }
    }
    
    func filter(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        var data = songModel
        if (searchText?.count)! > 0 {
            data = self.songModel.filter({( song: Songs) -> Bool in
                if (self.preferences.string(forKey: "searchBy")?.equalsIgnoreCase("searchByContent"))! {
                    let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!) || (song.comment as NSString).localizedCaseInsensitiveContains(searchText!) || (song.lyrics as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                } else {
                    let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!) || (song.comment as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                }
            })
        }
        self.filteredSongModel = data
        sortSongModel();
        tableView.reloadData()
    }
}

extension TitlesViewController: SearchDelegateFor4S {
    func reloadSearchData() {
        sortSongModel()
        tableView.reloadData()
    }
    
    func cancelSearch() {
        filteredSongModel = songModel
        sortSongModel()
        tableView.reloadData()
    }
    
}
