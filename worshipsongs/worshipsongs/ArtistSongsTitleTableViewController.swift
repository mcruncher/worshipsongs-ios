//
//  ArtistSongsTitleTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 08/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class ArtistSongsTitleTableViewController: UITableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate  {
    
    var artistName: String = ""
    fileprivate let preferences = UserDefaults.standard
    var songModel = [Songs]()
    var filteredSongModel = [Songs]()
    var databaseHelper = DatabaseHelper()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    var comment = ""
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModel()
        addLongPressGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filteredSongModel = songModel
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
    
    fileprivate func addLongPressGestureRecognizer() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TitlesTableViewController.onCellViewLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    internal func onCellViewLongPress(_ longPressGesture: UILongPressGestureRecognizer) {
        let pressingPoint = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: pressingPoint)
        if longPressGesture.state == UIGestureRecognizerState.began {
            self.present(self.getConfirmationAlertController(indexPath!), animated: true, completion: nil)
        }
    }
    
    fileprivate func getConfirmationAlertController(_ indexPath: IndexPath) -> UIAlertController {
        let confirmationAlertController = self.getMoveController(indexPath)
        confirmationAlertController.addAction(self.getMoveAction(indexPath))
        confirmationAlertController.addAction(self.getCancelAction(indexPath))
        return confirmationAlertController
    }
    
    fileprivate func getMoveController(_ indexPath: IndexPath) -> UIAlertController {
        return UIAlertController(title: filteredSongModel[(indexPath as NSIndexPath).row].title, message: "message.add".localized, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    fileprivate func getMoveAction(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            let song = self.filteredSongModel[indexPath.row]
            var favSong = [String]()
            if self.preferences.array(forKey: "favorite") != nil {
                favSong = self.preferences.array(forKey: "favorite") as! [String]
            }
            favSong.append(song.title)
            self.preferences.setValue(favSong, forKey: "favorite")
            self.preferences.synchronize()
        })
    }
    
    fileprivate func getCancelAction(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "No", style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
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
        cell.title.text = filteredSongModel[(indexPath as NSIndexPath).row].title
        if filteredSongModel[(indexPath as NSIndexPath).row].comment != nil && filteredSongModel[(indexPath as NSIndexPath).row].comment.contains("youtube") {
            cell.playImage.isHidden = false
        } else {
            cell.playImage.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        verseList = NSArray()
        songLyrics = filteredSongModel[(indexPath as NSIndexPath).row].lyrics as NSString
        songName = filteredSongModel[(indexPath as NSIndexPath).row].title
        if filteredSongModel[(indexPath as NSIndexPath).row].comment != nil {
            comment = filteredSongModel[(indexPath as NSIndexPath).row].comment
        } else {
            comment = ""
        }
        let verseOrder = filteredSongModel[(indexPath as NSIndexPath).row].verse_order
        if !verseOrder.isEmpty {
            verseList = splitVerseOrder(verseOrder)
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
        }
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
        self.filteredSongModel = data
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        filteredSongModel = songModel
        tableView.reloadData()
    }
    
    func refresh(_ sender:AnyObject)
    {
        filteredSongModel = songModel
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
