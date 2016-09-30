//
//  ArtistSongsTitleTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 08/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class ArtistSongsTitleTableViewController: UITableViewController, UISearchBarDelegate  {
    
    var artistName: String = ""
    var songModel = [Songs]()
    var filteredSongModel = [Songs]()
    var databaseHelper = DatabaseHelper()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createSearchBar()
    }
    
    func updateModel() {
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(ArtistSongsTitleTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        self.navigationItem.title = artistName
        filteredSongModel = songModel
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredSongModel[(indexPath as NSIndexPath).row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        verseList = NSArray()
        songLyrics = filteredSongModel[(indexPath as NSIndexPath).row].lyrics as NSString
        songName = filteredSongModel[(indexPath as NSIndexPath).row].title
        let verseOrder = filteredSongModel[(indexPath as NSIndexPath).row].verse_order
        if !verseOrder.isEmpty {
            verseList = splitVerseOrder(verseOrder)
        }
        hideSearchBar()
        performSegue(withIdentifier: "artistSongs", sender: self)
        
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray
    {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "artistSongs") {
            let songsTableViewController = segue.destination as! SongsTableViewController;
            songsTableViewController.verseOrder = verseList
            songsTableViewController.songLyrics = songLyrics
            songsTableViewController.songName = songName
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
