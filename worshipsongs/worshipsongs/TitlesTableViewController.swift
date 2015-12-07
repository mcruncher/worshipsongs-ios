//
//  TitlesTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class TitlesTableViewController: AbstractViewController {
    
    var songModel = [Songs]()
    var filteredSongModel = [Songs]()
    var databaseHelper = DatabaseHelper()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(self.searchBar)
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
    
    override func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        super.searchBarSearchButtonClicked(searchBar)
        tableView.reloadData()
    }
    
    override func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        super.searchBarCancelButtonClicked(searchBar)
        filteredSongModel = songModel
        tableView.reloadData()
    }
}
