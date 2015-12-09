//
//  TitlesTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class TitlesTableViewController: UITableViewController, UISearchBarDelegate {
    
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
    
    override func viewWillAppear(animated: Bool) {
        createSearchBar()
    }
        
    func updateModel() {
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: "refresh:", forControlEvents:UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresh)
        songModel = databaseHelper.getSongModel()
        filteredSongModel = songModel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredSongModel.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = filteredSongModel[indexPath.row].title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        verseList = NSArray()
        songLyrics = filteredSongModel[indexPath.row].lyrics
        songName = filteredSongModel[indexPath.row].title
        let verseOrder = filteredSongModel[indexPath.row].verse_order
        if !verseOrder.isEmpty {
            verseList = splitVerseOrder(verseOrder)
        }
        hideSearchBar()
        performSegueWithIdentifier("songs", sender: self)
        
    }
    
    func splitVerseOrder(verseOrder: String) -> NSArray
    {
        return verseOrder.componentsSeparatedByString(" ") as NSArray
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "songs") {
            let songsTableViewController = segue.destinationViewController as! SongsTableViewController;
            songsTableViewController.verseOrder = verseList
            songsTableViewController.songLyrics = songLyrics
            songsTableViewController.songName = songName
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = [(Songs)]()
        data = self.songModel.filter({( song: Songs) -> Bool in
            let stringMatch = (song.title as NSString).localizedCaseInsensitiveContainsString(searchText!)
            return (stringMatch.boolValue)
            
        })
        self.filteredSongModel = data
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        hideSearchBar()
        filteredSongModel = songModel
        tableView.reloadData()
    }
    
    func refresh(sender:AnyObject)
    {
        filteredSongModel = songModel
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    func createSearchBar()
    {
        // Search bar
        let searchBarFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 44);
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self;
        searchBar.showsCancelButton = true;
        searchBar.tintColor = UIColor.grayColor()
        self.addSearchBarButton()
    }
    
    func addSearchBarButton(){
        self.tabBarController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
    }
    
    func searchButtonItemClicked(sender:UIBarButtonItem){
        self.tabBarController?.navigationItem.titleView = searchBar;
        self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = false
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    func hideSearchBar() {
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = true
        self.searchBar.text = ""
        self.tabBarController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
    }
}
