//
// author: Madasamy, Vignesh Palanisamy
// version: 1.0.0
//

import UIKit

class ArtistsTableViewController: UITableViewController   {
    
    var authorModel = [Author]()
    var artistName: String = ""
    var filteredAuthorModel = [Author]()
    var databaseHelper = DatabaseHelper()
    var songsModel = [Song]()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    fileprivate var songTabBarController: SongsTabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "artists".localized
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(ArtistsTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        self.tableView.tableFooterView = getTableFooterView()
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: (self.tabBarController?.tabBar.frame.height)!))
        return footerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "artists".localized
        songTabBarController?.searchDelegate = self
        songTabBarController?.searchDelegate4S = self
        authorModel = databaseHelper.findAuthors()
        filteredAuthorModel = authorModel
        tableView.reloadData()
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
        return filteredAuthorModel.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if "tamil".equalsIgnoreCase(self.preferences.string(forKey: "language")!) {
            cell.textLabel?.text = filteredAuthorModel[indexPath.row].displayNameTamil
        } else {
            cell.textLabel?.text = filteredAuthorModel[indexPath.row].displayNameEnglish
        }
        cell.detailTextLabel?.text = NSString(format: "no.songs".localized as NSString, String(filteredAuthorModel[indexPath.row].noOfSongs)) as String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songTabBarController?.closeSearchBar()
        if "tamil".equalsIgnoreCase(self.preferences.string(forKey: "language")!) {
            artistName = filteredAuthorModel[(indexPath as NSIndexPath).row].displayNameTamil
        } else {
            artistName = filteredAuthorModel[(indexPath as NSIndexPath).row].displayNameEnglish
        }
        songsModel = databaseHelper.findSongs(byAuthorId: filteredAuthorModel[(indexPath as NSIndexPath).row].id)
        performSegue(withIdentifier: "artistTitle", sender: self)
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray
    {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "artistTitle") {
            let titleTableViewController = segue.destination as! ArtistSongsTitleTableViewController
            titleTableViewController.artistName = artistName
            titleTableViewController.songModel = songsModel
            titleTableViewController.songSelectionDelegate = songTabBarController?.songdelegate
        }
    }
    
    @objc func refresh(_ sender:AnyObject)
    {
        filteredAuthorModel = authorModel
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
}

extension ArtistsTableViewController : SearchDelegateIOS11 {
    func filter(_ searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = authorModel
        if (searchText?.count)! > 0 {
            data = self.authorModel.filter({( song: Author) -> Bool in
                let stringMatch = (song.displayName as NSString).localizedCaseInsensitiveContains(searchText!)
                return (stringMatch)
            })
        }
        self.filteredAuthorModel = data
        tableView.reloadData()
    }        
}

extension ArtistsTableViewController: SearchDelegateFor4S {
    func reloadSearchData() {
        tableView.reloadData()
    }
    
    func cancelSearch() {
        filteredAuthorModel = authorModel
        tableView.reloadData()
    }
    
}

