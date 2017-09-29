//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit

class ArtistSongsTitleTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    fileprivate let searchByTitle = "searchByTitle"
    fileprivate let searchByNumber = "searchByNumber"
    fileprivate let searchByContent = "searchByContent"
    var artistName: String = ""
    fileprivate let preferences = UserDefaults.standard
    var songModel = [Songs]()
    var filteredSongModel = [Songs]()
    var databaseHelper = DatabaseHelper()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    var comment = ""
    fileprivate var isLanguageTamil = true
    
    fileprivate var addToFav: Songs!
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    var songTabBarController: SongsTabBarViewController?
    var transparentSearchEnabled = false
    fileprivate var enableBackButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModel()
        addLongPressGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isLanguageTamil = preferences.string(forKey: "language") == "tamil"
        filteredSongModel = songModel
        sortSongModel()
        createSearchBar()
        addLeftBarButton()
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
        let selectedSong = filteredSongModel[indexPath.row]
        songTabBarController?.songdelegate?.songSelected(selectedSong)
        hideSearchBar()
        if let detailViewController = songTabBarController?.songdelegate as? SongWithVideoViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
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
        if (segue.identifier == "songsWithVideo") {
            let songsTableViewController = segue.destination as! SongWithVideoViewController
            songsTableViewController.verseOrder = verseList
            songsTableViewController.songLyrics = songLyrics
            songsTableViewController.songName = songName
            songsTableViewController.comment = comment
            songsTableViewController.authorName = artistName
        } else if (segue.identifier == CommonConstansts.manageFav) {
            let manageFavoritesController = segue.destination as! ManageFavoritesController
            manageFavoritesController.song = addToFav
        }
    }
    
    func refresh(_ sender:AnyObject)
    {
        filteredSongModel = songModel
        sortSongModel()
        self.tableView.reloadData()
        self.refresh.endRefreshing()
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
                    if (self.preferences.string(forKey: CommonConstansts.searchKey)?.equalsIgnoreCase("searchByTitle"))! {
                        return song.title.localizedCaseInsensitiveContains(searchText!)
                    } else if (self.preferences.string(forKey: CommonConstansts.searchKey)?.equalsIgnoreCase("searchByNumber"))! {
                        return song.songBookNo.equalsIgnoreCase(searchText!)
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
    
    func searchButtonItemClicked(_ sender:UIBarButtonItem){
        self.navigationItem.titleView = searchBar;
        enableBackButton = false
        addLeftBarButton()
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    func hideSearchBar() {
        self.navigationItem.titleView = nil
        enableBackButton = true
        addLeftBarButton()
        self.searchBar.text = ""
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistSongsTitleTableViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
}

//MARK:- Navigation button
extension ArtistSongsTitleTableViewController{
    
    fileprivate func addLeftBarButton() {
        if transparentSearchEnabled {
            let button = UIButton()
            if enableBackButton {
                button.setTitle("back".localized, for: UIControlState())
                button.setTitleColor(.gray, for: UIControlState())
            } else {
                let searchBy = self.preferences.string(forKey: CommonConstansts.searchKey)
                let imageName = searchByNumber.equalsIgnoreCase(searchBy!) ? searchByTitle : searchBy
                let origImage = UIImage(named: imageName!)
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                button.setImage(tintedImage, for: UIControlState())
                button.tintColor = .gray
            }
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.addTarget(self, action: #selector(ArtistSongsTitleTableViewController.onTapLeftButton),for: .touchUpInside)
            let uiBarButtonItem = UIBarButtonItem()
            uiBarButtonItem.customView = button
            self.navigationItem.setLeftBarButton(uiBarButtonItem, animated: true)
        }
    }
    
    func onTapLeftButton() {
        if enableBackButton {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let optionMenu = UIAlertController(title: nil, message: "searchBy".localized, preferredStyle: .actionSheet)
            optionMenu.addAction(searchByAction(searchByTitle))
            optionMenu.addAction(searchByAction(searchByNumber))
            optionMenu.addAction(searchByAction(searchByContent))
            optionMenu.addAction(getCancelAction())
            optionMenu.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    fileprivate func getCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
    }
    func searchByAction(_ option: String) -> UIAlertAction {
        return UIAlertAction(title: option.localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.preferences.set(option, forKey: CommonConstansts.searchKey)
            self.preferences.synchronize()
            self.addLeftBarButton()
        })
    }
}
