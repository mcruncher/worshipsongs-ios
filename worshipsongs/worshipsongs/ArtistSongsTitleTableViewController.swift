//
//  ArtistSongsTitleTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 08/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class ArtistSongsTitleTableViewController: UITableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
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
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    var songTabBarController: SongsTabBarViewController?
    
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
        }
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
                let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!) || (song.comment as NSString).localizedCaseInsensitiveContains(searchText!)
                return (stringMatch)
                
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
    
    func refresh(_ sender:AnyObject)
    {
        filteredSongModel = songModel
        sortSongModel()
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    func addSearchBarButton(){
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistSongsTitleTableViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func searchButtonItemClicked(_ sender:UIBarButtonItem){
        self.navigationItem.titleView = searchBar;
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    
    func hideSearchBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.searchBar.text = ""
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistSongsTitleTableViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func createSearchBar()
    {
        // Search bar
        let searchBarFrame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: 44);
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self;
        searchBar.showsCancelButton = true;
        searchBar.tintColor = UIColor.gray
        self.addSearchBarButton()
    }
    
}
