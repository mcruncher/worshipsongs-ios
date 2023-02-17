//
// author: Madasamy, Vignesh Palanisamy
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
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "song_books".localized
        songTabBarController?.searchDelegate = self
        songTabBarController?.searchDelegate4S = self
        songBooks = songBookService.findAll()
        filterSongBooks = songBooks!
        tableView.reloadData()
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
        cell.detailTextLabel?.text = NSString(format: "no.songs".localized as NSString, String(songBook.noOfSongs)) as String
        return cell
    }
}

// MARK: - Table view delegate
extension SongBookController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songTabBarController?.closeSearchBar()
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
            titleTableViewController.transparentSearchEnabled = true
            titleTableViewController.songSelectionDelegate = songTabBarController?.songdelegate
        }
    }
}

extension SongBookController: SearchDelegateFor4S {
    func reloadSearchData() {
        tableView.reloadData()
    }
    
    func cancelSearch() {
        filterSongBooks = songBooks!
        tableView.reloadData()
    }
    
}


extension SongBookController : SearchDelegateIOS11 {
    func filter(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        var data = songBooks
        let tamilLocalizaied = CommonConstansts.tamilKey.equalsIgnoreCase(self.preferences.string(forKey:
            CommonConstansts.languageKey)!)
        if (searchText?.count)! > 0 {
            data = (self.songBooks?.filter({( song: SongBook) -> Bool in
                let name = tamilLocalizaied ? song.tamilName : song.englishName
                return name.localizedCaseInsensitiveContains(searchText!)
            }))!
        }
        self.filterSongBooks = data!
        tableView.reloadData()
    }
}
