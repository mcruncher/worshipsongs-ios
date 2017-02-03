//
//  FavoritesTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 16/11/2016.
//  Copyright © 2016 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController, UISearchBarDelegate {

    var songModel = [Songs]()
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
        cell.title.text = songModel[(indexPath as NSIndexPath).row].title
        if songModel[(indexPath as NSIndexPath).row].comment != nil && songModel[(indexPath as NSIndexPath).row].comment.contains("youtube") {
            cell.playImage.isHidden = false
        } else {
            cell.playImage.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        verseList = NSArray()
        songLyrics = songModel[(indexPath as NSIndexPath).row].lyrics as NSString
        songName = songModel[(indexPath as NSIndexPath).row].title
        authorName = databaseHelper.getArtistName(songModel[(indexPath as NSIndexPath).row].id)
        let verseOrder = songModel[(indexPath as NSIndexPath).row].verse_order
        if !verseOrder.isEmpty {
            verseList = splitVerseOrder(verseOrder)
        }
        if songModel[(indexPath as NSIndexPath).row].comment != nil {
            comment = songModel[(indexPath as NSIndexPath).row].comment
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
            var favSong = self.preferences.array(forKey: "favorite") as! [String]
            let index = favSong.index(of: self.songModel[(indexPath as NSIndexPath).row].title)
            favSong.remove(at: index!)
            self.preferences.setValue(favSong, forKey: "favorite")
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
        if self.preferences.array(forKey: "favorite") != nil {
            songTitles = self.preferences.array(forKey: "favorite") as! [String]
            songModel = databaseHelper.getSongsModelTitles(songTitles)
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
        var data = [(Songs)]()
        data = self.songModel.filter({( song: Songs) -> Bool in
            let stringMatch = (song.title as NSString).localizedCaseInsensitiveContains(searchText!)
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
