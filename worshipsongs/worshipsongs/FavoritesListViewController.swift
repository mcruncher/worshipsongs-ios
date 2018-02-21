//
// author: Vignesh Palanisamy
// version: 2.3.x
//

import UIKit

class FavoritesListViewController: UITableViewController {
    
    fileprivate let preferences = UserDefaults.standard
    var pagingSpinner = UIActivityIndicatorView()
    var favorites = [String]()
    var filteredFavorites = [String]()
    var selectedFavorite = ""
    fileprivate var songTabBarController: SongsTabBarViewController?
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "favorites".localized
        favorites = (preferences.array(forKey: CommonConstansts.favorites) as? [String])!
        filteredFavorites = favorites
        tableView.reloadData()
        self.tableView.tableFooterView = getTableFooterView()
        pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        pagingSpinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height)
        pagingSpinner.hidesWhenStopped = true
        pagingSpinner.center = self.view.center
        self.view.addSubview(pagingSpinner)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        songTabBarController = tabBarController as? SongsTabBarViewController
        songTabBarController?.navigationItem.title = "favorites".localized
        favorites = (preferences.array(forKey: CommonConstansts.favorites) as? [String])!
        filteredFavorites = favorites
        songTabBarController?.searchDelegate = self
        songTabBarController?.searchDelegate4S = self
        tableView.reloadData()
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: (self.tabBarController?.tabBar.frame.height)!))
        footerview.backgroundColor = UIColor.groupTableViewBackground
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 15))
        label.text = "message.favorite".localized
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textColor = UIColor.gray
        footerview.addSubview(label)
        return footerview
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFavorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstansts.favorite, for: indexPath)
        cell.textLabel?.text = filteredFavorites[indexPath.row]
        var count = 0
        if self.preferences.dictionaryRepresentation().keys.contains(filteredFavorites[indexPath.row]) {
            let decoded  = self.preferences.object(forKey: filteredFavorites[indexPath.row]) as! Data
            let favSongs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
            count = favSongs.count
        }
        cell.detailTextLabel?.text = NSString(format: "no.songs".localized as NSString, String(count)) as String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songTabBarController?.closeSearchBar()
        selectedFavorite = filteredFavorites[indexPath.row]
        performSegue(withIdentifier: CommonConstansts.favorite, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier?.equalsIgnoreCase(CommonConstansts.favorite))! {
            let favoritesController: FavoritesTableViewController = segue.destination as! FavoritesTableViewController
            favoritesController.favorite = selectedFavorite
            favoritesController.songTabBarController = songTabBarController
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = getTableViewRowAction(indexPath)
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    fileprivate func getTableViewRowAction(_ indexPath: IndexPath) -> UITableViewRowAction {
        return UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "remove".localized) { (action, indexPath) -> Void in
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
        return UIAlertAction(title: "yes".localized, style: .default, handler: {(alert: UIAlertAction!) -> Void in
            self.pagingSpinner.backgroundColor = UIColor(white: 1, alpha: 0.5)
            self.pagingSpinner.isHidden = false
            self.pagingSpinner.startAnimating()
            let favoriteName = self.filteredFavorites[indexPath.row]
            var newFavorites = [String]()
            for index in 0..<self.favorites.count {
                if !self.favorites[index].equalsIgnoreCase(favoriteName) {
                    newFavorites.append(self.favorites[index])
                }
            }
            self.preferences.set(newFavorites, forKey: CommonConstansts.favorites)
            self.preferences.removeObject(forKey: favoriteName)
            self.filteredFavorites.remove(at: indexPath.row)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.tableView.reloadData()
                self.pagingSpinner.stopAnimating()
            }
        })
    }
    
    fileprivate func getCancelAction(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "no".localized, style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableViewRowAnimation.automatic)
        })
    }
    
}

extension FavoritesListViewController : SearchDelegateIOS11 {
    func filter(_ searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = favorites
        if (searchText?.characters.count)! > 0 {
            data = self.filteredFavorites.filter({ (matchedText) -> Bool in
                return matchedText.localizedCaseInsensitiveContains(searchText!)
            })
        }
        self.filteredFavorites = data
        tableView.reloadData()
    }
    
    func hideSearch() {
        if DeviceUtils.isIpad() {
            songTabBarController?.closeSearchBar()
            filteredFavorites = favorites
            tableView.reloadData()
        }
    }
    
}

extension FavoritesListViewController: SearchDelegateFor4S {
    func reloadSearchData() {
        tableView.reloadData()
    }
    
    func cancelSearch() {
        filteredFavorites = favorites
        tableView.reloadData()
    }
    
}

