//
//  ArtistsTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 08/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class ArtistsTableViewController: UITableViewController, UISearchBarDelegate  {
    
    var authorModel = [Author]()
    var artistName: String = ""
    var filteredAuthorModel = [Author]()
    var databaseHelper = DatabaseHelper()
    var songsModel = [Songs]()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorModel = databaseHelper.getArtistModel()
        filteredAuthorModel = authorModel
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: "refresh:", forControlEvents:UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresh)
    }
    
    override func viewWillAppear(animated: Bool) {
        createSearchBar()
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
        return filteredAuthorModel.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = filteredAuthorModel[indexPath.row].displayName
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        hideSearchBar()
        artistName = filteredAuthorModel[indexPath.row].displayName
        songsModel = databaseHelper.getArtistSongsModel(filteredAuthorModel[indexPath.row].id)
        performSegueWithIdentifier("artistTitle", sender: self)
        
    }
    
    func splitVerseOrder(verseOrder: String) -> NSArray
    {
        return verseOrder.componentsSeparatedByString(" ") as NSArray
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "artistTitle") {
            let titleTableViewController = segue.destinationViewController as! ArtistSongsTitleTableViewController
            titleTableViewController.artistName = artistName
            titleTableViewController.songModel = songsModel
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(self.searchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = [(Author)]()
        data = self.authorModel.filter({( song: Author) -> Bool in
            let stringMatch = (song.displayName as NSString).localizedCaseInsensitiveContainsString(searchText!)
            return (stringMatch.boolValue)
            
        })
        self.filteredAuthorModel = data
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        hideSearchBar()
        filteredAuthorModel = authorModel
        tableView.reloadData()
    }
    
    func refresh(sender:AnyObject)
    {
        filteredAuthorModel = authorModel
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
