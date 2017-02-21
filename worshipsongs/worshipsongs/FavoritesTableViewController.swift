//
//  FavoritesTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 16/11/2016.
//  Copyright © 2016 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController, UISearchBarDelegate {

    var songModel = [FavoritesSong]()
    var songOrder = [Int]()
    var songTitles = [String]()
    var databaseHelper = DatabaseHelper()
    var refresh = UIRefreshControl()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    var comment = ""
    fileprivate let preferences = UserDefaults.standard
    var searchBar: UISearchBar!
    var authorName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.title = "favorites".localized
        tableView.contentInset = UIEdgeInsetsMake(0, 0, (self.tabBarController?.tabBar.frame.height)!, 0)
        self.tableView.tableFooterView = getTableFooterView()
        updateModel()
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(FavoritesTableViewController.longPressGestureRecognized))
        tableView.addGestureRecognizer(longpress)
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath as NSIndexPath?
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(inputView: cell!)
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
            
        case UIGestureRecognizerState.changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath as? IndexPath)) {
                tableView.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                Path.initialIndexPath = indexPath as NSIndexPath?
            }
            
        default:
            let cell = tableView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
            updateSongOrder()
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func updateSongOrder() {
        var newSongOrder = [FavoritesSongsWithOrder]()
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! TitleTableViewCell
            let id = cell.id.text
            let favSong = FavoritesSongsWithOrder(orderNo: i, songId: id!, songListName: "favorite")
            newSongOrder.append(favSong)
        }
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newSongOrder)
        self.preferences.set(encodedData, forKey: "favorite")
        self.preferences.synchronize()
    }
    
    func getTableFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 25))
        footerview.backgroundColor = UIColor.groupTableViewBackground
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 15))
        label.text = "message.favorite".localized
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textColor = UIColor.gray
        footerview.addSubview(label)
        return footerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let songTabBarController = tabBarController as! SongsTabBarViewController
        songTabBarController.navigationItem.title = "favorites".localized
        createSearchBar()
        refresh(self)
    }
    
    func updateModel() {
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(FavoritesTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        refresh(self)
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
        return songModel.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TitleTableViewCell
        cell.title.text = songModel[(indexPath as NSIndexPath).row].songs.title
        cell.id.text = songModel[(indexPath as NSIndexPath).row].songs.id
        if songModel[(indexPath as NSIndexPath).row].songs.comment != nil && songModel[(indexPath as NSIndexPath).row].songs.comment.contains("youtube") {
            cell.playImage.isHidden = false
        } else {
            cell.playImage.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        verseList = NSArray()
        let songs = songModel[(indexPath as NSIndexPath).row].songs
        
        songLyrics = songs.lyrics as NSString
        songName = songs.title
        authorName = databaseHelper.getArtistName(songs.id)
        let verseOrder = songs.verse_order
        if !verseOrder.isEmpty {
            verseList = splitVerseOrder(verseOrder)
        }
        if songs.comment != nil {
            comment = songs.comment
        } else {
            comment = ""
        }
        hideSearchBar()
        performSegue(withIdentifier: "songsWithVideo", sender: self)
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
            songsTableViewController.authorName = authorName
        }
    }
    
    @objc(tableView:editActionsForRowAtIndexPath:) override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = getTableViewRowAction(indexPath)
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    fileprivate func getTableViewRowAction(_ indexPath: IndexPath) -> UITableViewRowAction {
        return UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Remove") { (action, indexPath) -> Void in
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
        return UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            var newSongOrder = [FavoritesSongsWithOrder]()
            for i in 0..<self.tableView.numberOfRows(inSection: 0) {
                if i != indexPath.row {
                    let favSong = FavoritesSongsWithOrder(orderNo: i, songId: self.songModel[i].songs.id, songListName: self.songModel[i].favoritesSongsWithOrder.songListName)
                    newSongOrder.append(favSong)
                }
            }
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newSongOrder)
            self.preferences.set(encodedData, forKey: "favorite")
            self.preferences.synchronize()
            self.refresh(self)
        })
    }
    
    fileprivate func getCancelAction(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "No", style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableViewRowAnimation.automatic)
        })
    }

    func refresh(_ sender:AnyObject)
    {
        if self.preferences.data(forKey: "favorite") != nil {
            let decoded  = self.preferences.object(forKey: "favorite") as! Data
            let favoritesSongsWithOrders = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [FavoritesSongsWithOrder]
            var favoritesSongs = [FavoritesSong]()
            for favoritesSongsWithOrder in favoritesSongsWithOrders {
                let songs = databaseHelper.getSongsModelByIds([favoritesSongsWithOrder.songId])
                if songs.count > 0 {
                   favoritesSongs.append(FavoritesSong(songs: songs[0], favoritesSongsWithOrder: favoritesSongsWithOrder))
                }
            }
            songModel = favoritesSongs
            songModel.sort(by: { (fav1, fav2) -> Bool in
                fav1.favoritesSongsWithOrder.orderNo < fav2.favoritesSongsWithOrder.orderNo
            })
        }
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = [(FavoritesSong)]()
        data = self.songModel.filter({( song: FavoritesSong) -> Bool in
            let stringMatch = (song.songs.title as NSString).localizedCaseInsensitiveContains(searchText!)
            return (stringMatch)
            
        })
        self.songModel = data
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        refresh(self)
        tableView.reloadData()
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
    
    func addSearchBarButton(){
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(TitlesTableViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func searchButtonItemClicked(_ sender:UIBarButtonItem){
        self.tabBarController?.navigationItem.titleView = searchBar;
        self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = false
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    func hideSearchBar() {
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = true
        self.searchBar.text = ""
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(TitlesTableViewController.searchButtonItemClicked(_:))), animated: true)
    }

}
