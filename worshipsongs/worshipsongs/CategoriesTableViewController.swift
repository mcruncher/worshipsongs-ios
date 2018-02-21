//
//
// author: Vignesh Palanisamy
// version: 2.1.0
//

import UIKit

class CategoriesTableViewController: UITableViewController   {
    
    var categoryModel = [Category]()
    var categoryName: String = ""
    var filteredCategoryModel = [Category]()
    var databaseHelper = DatabaseHelper()
    var songsModel = [Songs]()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    fileprivate var songTabBarController: SongsTabBarViewController?
    fileprivate let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "categories".localized
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "refresh".localized)
        refresh.addTarget(self, action: #selector(CategoriesTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        self.tableView.tableFooterView = getTableFooterView()
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: (self.tabBarController?.tabBar.frame.height)!))
        return footerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "categories".localized
        categoryModel = databaseHelper.findCategory()
        filteredCategoryModel = categoryModel
        songTabBarController?.searchDelegate = self
        songTabBarController?.searchDelegate4S = self
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategoryModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if "tamil".equalsIgnoreCase(self.preferences.string(forKey: "language")!) {
            cell.textLabel?.text = filteredCategoryModel[indexPath.row].nameTamil
        } else {
            cell.textLabel?.text = filteredCategoryModel[indexPath.row].nameEnglish
        }
        cell.detailTextLabel?.text = NSString(format: "no.songs".localized as NSString, String(filteredCategoryModel[indexPath.row].noOfSongs)) as String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songTabBarController?.closeSearchBar()
        if "tamil".equalsIgnoreCase(self.preferences.string(forKey: "language")!) {
            categoryName = filteredCategoryModel[(indexPath as NSIndexPath).row].nameTamil
        } else {
            categoryName = filteredCategoryModel[(indexPath as NSIndexPath).row].nameEnglish
        }
        songsModel = databaseHelper.findCategorySongs(filteredCategoryModel[(indexPath as NSIndexPath).row].id)
        performSegue(withIdentifier: "artistTitle", sender: self)
        
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "artistTitle") {
            let titleTableViewController = segue.destination as! ArtistSongsTitleTableViewController
            titleTableViewController.artistName = categoryName
            titleTableViewController.songModel = songsModel
            titleTableViewController.songSelectionDelegate = songTabBarController?.songdelegate
        }
    }
    
    @objc func refresh(_ sender:AnyObject) {
        filteredCategoryModel = categoryModel
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
}

extension CategoriesTableViewController : SearchDelegateIOS11 {
    func filter(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        var data = categoryModel
        if (searchText?.characters.count)! > 0 {
            data = self.categoryModel.filter({( category: Category) -> Bool in
                let stringMatch = (category.name as NSString).localizedCaseInsensitiveContains(searchText!)
                return (stringMatch)
            })
        }
        self.filteredCategoryModel = data
        tableView.reloadData()
    }
    
    func hideSearch() {
        if DeviceUtils.isIpad() {
            songTabBarController?.closeSearchBar()
            filteredCategoryModel = categoryModel
            tableView.reloadData()
        }
    }

}

extension CategoriesTableViewController: SearchDelegateFor4S {
    func reloadSearchData() {
        tableView.reloadData()
    }
    
    func cancelSearch() {
        filteredCategoryModel = categoryModel
        tableView.reloadData()
    }
    
}

