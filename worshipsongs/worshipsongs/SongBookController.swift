//
// author: Madasamy
// version: 2.3.x
//

import UIKit

class SongBookController: UITableViewController {
    
    fileprivate let cellIdentifier = "cell"
    fileprivate let artistTitleIdentifier = "artistTitle"
    fileprivate let preferences = UserDefaults.standard
    fileprivate let songBookService = SongBookService()
    fileprivate var songBooks: [SongBook]?
    fileprivate var filterSongBooks = [SongBook]()
    fileprivate var songTabBarController: SongsTabBarViewController?
    
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "song_books".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let songTabBarController = tabBarController as! SongsTabBarViewController
        songTabBarController.navigationItem.title = "song_books".localized
        songBooks = songBookService.findAll()
        filterSongBooks = songBooks!
        createSearchBar()
    }
}

// MARK: - Table view data source
extension SongBookController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterSongBooks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let songBook =  filterSongBooks[indexPath.row]
        cell.textLabel?.text = CommonConstansts.tamilKey.equalsIgnoreCase(self.preferences.string(forKey:
            CommonConstansts.languageKey)!) ? songBook.tamilName : songBook.englishName
        return cell
    }
}

// MARK: - Table view delegate
extension SongBookController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideSearchBar()
        performSegue(withIdentifier: artistTitleIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (artistTitleIdentifier.equalsIgnoreCase(segue.identifier!)) {
            let songBook = filterSongBooks[(tableView.indexPathForSelectedRow?.row)!]
            let songs = songBookService.findBySongBookId(songBook.id)
            let titleTableViewController = segue.destination as! ArtistSongsTitleTableViewController
            titleTableViewController.artistName = CommonConstansts.tamilKey.equalsIgnoreCase(self.preferences.string(forKey:
                CommonConstansts.languageKey)!) ? songBook.tamilName : songBook.englishName
            titleTableViewController.songModel = songs
            titleTableViewController.songTabBarController = songTabBarController
        }
    }
}

extension SongBookController: UISearchBarDelegate {
    
    func createSearchBar()
    {
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
    
    func addSearchBarButton(){
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(SongBookController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func searchButtonItemClicked(_ sender:UIBarButtonItem){
        self.tabBarController?.navigationItem.titleView = searchBar
        self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = false
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    func hideSearchBar() {
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = true
        self.searchBar.text = ""
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(SongBookController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(self.searchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        var data = songBooks
        let tamilLocalizaied = CommonConstansts.tamilKey.equalsIgnoreCase(self.preferences.string(forKey:
            CommonConstansts.languageKey)!)
        if (searchText?.characters.count)! > 0 {
            data = (self.songBooks?.filter({( song: SongBook) -> Bool in
                let name = tamilLocalizaied ? song.tamilName : song.englishName
                return name.localizedCaseInsensitiveContains(searchText!)
            }))!
        }
        self.filterSongBooks = data!
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        filterSongBooks = songBooks!
        tableView.reloadData()
    }
}

extension SongBookController:  TitleOrContentBaseSearchDelegate {
    func hideSearch() {
        if DeviceUtils.isIpad() {
            hideSearchBar()
            filterSongBooks = songBooks!
            tableView.reloadData()
        }
    }
}
