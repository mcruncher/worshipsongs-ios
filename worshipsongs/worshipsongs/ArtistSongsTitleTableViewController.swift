//
//  ArtistSongsTitleTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 08/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class ArtistSongsTitleTableViewController: TitlesTableViewController {
    
    var artistName: String = ""

    override func viewDidLoad() {
       super.viewDidLoad()
        self.navigationItem.title = artistName
    }
    
    override func updateModel() {
        filteredSongModel = songModel
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
        performSegueWithIdentifier("artistSongs", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "artistSongs") {
            let songsTableViewController = segue.destinationViewController as! SongsTableViewController;
            songsTableViewController.verseOrder = verseList
            songsTableViewController.songLyrics = songLyrics
            songsTableViewController.songName = songName
        }
    }
    
    override func addSearchBarButton(){
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
    }
    
    override func searchButtonItemClicked(sender:UIBarButtonItem){
        self.navigationItem.titleView = searchBar;
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }

    
    override func hideSearchBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.leftBarButtonItem?.enabled = true
        self.searchBar.text = ""
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
    }

}
