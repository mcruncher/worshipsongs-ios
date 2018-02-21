//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit

class ArtistSongsTitleTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
   
    var artistName: String = ""
    fileprivate let preferences = UserDefaults.standard
    var songModel = [Songs]()
    var filteredSongModel = [Songs]()
    var databaseHelper = DatabaseHelper()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    var comment = ""
    var selectedSong: Songs!
    fileprivate var isLanguageTamil = true
    
    fileprivate var addToFav: Songs!
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    var songSelectionDelegate: SongSelectionDelegate?
    var transparentSearchEnabled = false
    fileprivate var enableBackButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        if #available(iOS 11.0, *) {
            searchController.obscuresBackgroundDuringPresentation = false
            self.navigationItem.searchController = searchController
            self.definesPresentationContext = true
        } else {
            createSearchBar()
        }
        updateModel()
        addLongPressGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        filteredSongModel = songModel
        sortSongModel()
        tableView.reloadData()
    }
    
    func updateModel() {
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(ArtistSongsTitleTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        self.navigationItem.title = artistName
    }
    
    func sortSongModel()
    {
        if transparentSearchEnabled {
            filteredSongModel = filteredSongModel.sorted(){(song1, song2) -> Bool in
                return getSongBookNumber(song1) < getSongBookNumber(song2)
            }
        } else if isLanguageTamil {
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
    
    fileprivate func addLongPressGestureRecognizer() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TitlesViewController.onCellViewLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    internal func onCellViewLongPress(_ longPressGesture: UILongPressGestureRecognizer) {
        let pressingPoint = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: pressingPoint)
        if indexPath != nil && longPressGesture.state == UIGestureRecognizerState.began {
            addToFav = filteredSongModel[(indexPath?.row)!]
            performSegue(withIdentifier: CommonConstansts.manageFav, sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let songBookNo = getSongBookNumber(filteredSongModel[indexPath.row])
        if songBookNo > 0 {
            cell.songNumber.isHidden = false
            cell.songNumber.text = "songno".localized + " " +  String(songBookNo)
        } else {
            cell.songNumber.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSong = filteredSongModel[indexPath.row]
        songSelectionDelegate?.songSelected(selectedSong)
        hideSearchBar()
         if let detailViewController = songSelectionDelegate as? SongWithVideoViewController {
                splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: self)
            }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let song = filteredSongModel[indexPath.row]
        if getSongBookNumber(song) > 0, transparentSearchEnabled {
            return 65.0
        } else {
            return 50.0
        }
    }
    
    func getSongBookNumber(_ song: Songs) -> Int {
        guard  let songBookNumber = Int(song.songBookNo) else {
            return 0
        }
        return songBookNumber
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray
    {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == CommonConstansts.manageFav) {
            let manageFavoritesController = segue.destination as! ManageFavoritesController
            manageFavoritesController.song = addToFav
        }
    }
    
    @objc func refresh(_ sender:AnyObject)
    {
        filteredSongModel = songModel
        sortSongModel()
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
}

extension ArtistSongsTitleTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Filter the array using the filter method
        let searchText = searchController.searchBar.text
        var data = songModel
        if (searchText?.characters.count)! > 0 {
            data = self.songModel.filter({( song: Songs) -> Bool in
                if transparentSearchEnabled {
                    if (self.preferences.string(forKey: CommonConstansts.searchKey)?.equalsIgnoreCase(CommonConstansts.searchByTitleOrNumber))! {
                        return song.title.localizedCaseInsensitiveContains(searchText!) || song.songBookNo.equalsIgnoreCase(searchText!)
                    } else {
                        return song.lyrics.localizedCaseInsensitiveContains(searchText!) || song.comment.localizedCaseInsensitiveContains(searchText!)
                    }
                } else {
                    let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!) || (song.comment as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                }
            })
        }
        self.filteredSongModel = data
        sortSongModel()
        tableView.reloadData()
    }
}


extension ArtistSongsTitleTableViewController : UISearchBarDelegate {

    func createSearchBar()
    {
        let searchBarFrame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: 44);
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self;
        searchBar.showsCancelButton = true;
        searchBar.tintColor = UIColor.gray
        self.addSearchBarButton()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar)
        self.tableView.reloadData()
    }

    func filterContentForSearchText(_ searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = songModel
        if (searchText?.characters.count)! > 0 {
            data = self.songModel.filter({( song: Songs) -> Bool in
                if transparentSearchEnabled {
                    if (self.preferences.string(forKey: CommonConstansts.searchKey)?.equalsIgnoreCase(CommonConstansts.searchByTitleOrNumber))! {
                        return song.title.localizedCaseInsensitiveContains(searchText!) || song.songBookNo.equalsIgnoreCase(searchText!)
                    } else {
                        return song.lyrics.localizedCaseInsensitiveContains(searchText!) || song.comment.localizedCaseInsensitiveContains(searchText!)
                    }
                } else {
                    let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!) || (song.comment as NSString).localizedCaseInsensitiveContains(searchText!)
                    return (stringMatch)
                }
            })
        }
        self.filteredSongModel = data
        sortSongModel()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        sortSongModel()
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        filteredSongModel = songModel
        sortSongModel()
        tableView.reloadData()
    }

    func addSearchBarButton(){
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistSongsTitleTableViewController.searchButtonItemClicked(_:))), animated: true)
    }

    @objc func searchButtonItemClicked(_ sender:UIBarButtonItem){
        self.navigationItem.titleView = searchBar;
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }

    func hideSearchBar() {
        guard #available(iOS 11.0, *) else {
            self.navigationItem.titleView = nil
            self.searchBar.text = ""
            self.navigationItem.hidesBackButton = false
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistSongsTitleTableViewController.searchButtonItemClicked(_:))), animated: true)
            return
        }
    }
    
    func hideSearch() {
        if DeviceUtils.isIpad() {
            hideSearchBar()
            refresh(self)
            tableView.reloadData()
        }
    }

}
