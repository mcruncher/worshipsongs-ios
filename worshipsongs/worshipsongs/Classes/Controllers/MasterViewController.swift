//
//  MasterViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/16/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class MasterViewController: UITableViewController, UITableViewDataSource, UISearchBarDelegate  {
    let downloadService:DownloadService = DownloadService()
    let textAttributeService:TextAttributeService = TextAttributeService()
    let settingDataManager:SettingsDataManager = SettingsDataManager()
    var songTitles : NSMutableArray = []
    var songs = [String]()
    var dataCell: UITableViewCell?
    var mySearchBar: UISearchBar!
    var songData = [(Songs)]()
    var filteredData = [(Songs)]()
    var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var loadingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingLabel:UILabel=UILabel()
    var isParentView:Bool = false
    
    
    override func viewDidAppear(animated: Bool) {
//        if isParentView{
//            downloadService.checkConnectionAndDownloadFile()
//            loadingActivityIndicator.stopAnimating()
//            loadingView.removeFromSuperview()
//            container.removeFromSuperview()
//            //self.navigationItem.titleView = nil;
//            //self.navigationController?.navigationBar.tintColor = UIColor.blackColor();
//            self.songData = DatabaseHelper.instance.getSongModel()
//            tableView.dataSource = self
//            // Reload the table
//            self.tableView.reloadData()
//            isParentView = false
//            println("viewDidAppear finished")
//        }
    }
    

    override func viewDidLoad() {
        self.navigationItem.title = "Worship Songs"
        self.navigationController?.navigationBar.titleTextAttributes = textAttributeService.getDefaultNavigatioItemFontColor()
       // showActivityIndicatory(self.tableView)
        var myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
            self.view.bounds.size.width, 44);
        mySearchBar = UISearchBar(frame: myFrame)
        mySearchBar.delegate = self;
        mySearchBar.placeholder = "Search Songs"
        //display the cancel button next to the search bar
        mySearchBar.showsCancelButton = true;
        mySearchBar.tintColor = UIColor.grayColor()
         self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
        self.addSearchBarButton()
        self.addSettingsButton()
        
        self.songData = DatabaseHelper.instance.getSongModel()
        tableView.dataSource = self
        // Reload the table
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.titleView = nil;
        self.addSearchBarButton()
    }
    
    // Return the number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView && filteredData.count > 0 {
            return self.filteredData.count
        }
        else if filteredData.count == 0 && !mySearchBar.text.isEmpty {
            return 1
        }
        else if songData.count > 0{
            return self.songData.count
        }
        else{
            return 10
        }
        
    }
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        var dataCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(dataCell == nil)
        {
            dataCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        var song : Songs
        // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
        if tableView == self.tableView && filteredData.count > 0 {
            song = filteredData[indexPath.row]
            dataCell!.textLabel!.text = song.title
            dataCell!.textLabel?.font = textAttributeService.getDefaultFont()
        }
        else if filteredData.count == 0 && !mySearchBar.text.isEmpty {
            dataCell!.textLabel!.text = "No Results found!..."
        }
        else if songData.count > 0 {
            song = songData[indexPath.row]
            dataCell!.textLabel!.text = song.title
            dataCell!.textLabel?.font = textAttributeService.getDefaultFont()
        }
        else{
            dataCell!.textLabel!.text = ""
        }
        return dataCell!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
       // CellAnimator.animate(cell)
    }


    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.navigationBarHidden=true
        filterContentForSearchText(mySearchBar)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationItem.titleView = nil;
        self.mySearchBar.text = ""
        self.filteredData = [(Songs)]()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(mySearchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchBar: UISearchBar) {
        // Filter the array using the filter method
            var searchText = searchBar.text
            var data = [(Songs)]()
            data = self.songData.filter({( song: Songs) -> Bool in
            var stringMatch = (song.title as NSString).localizedCaseInsensitiveContainsString(searchText)
            return (stringMatch.boolValue)
                
        })
        
        if data.count != songData.count{
            self.filteredData = data
        }
    }
    
    
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var lyrics = String()
        var songName = String()
        var verseOrder = String()
        var verseList: NSArray = NSArray()
        if filteredData.count > 0{
            songName = filteredData[indexPath.row].title;
            lyrics = filteredData[indexPath.row].lyrics;
            verseOrder = filteredData[indexPath.row].verse_order;
        }
        else{
            songName = songData[indexPath.row].title;
            lyrics = songData[indexPath.row].lyrics;
            verseOrder = songData[indexPath.row].verse_order;
        }
        
        if !verseOrder.isEmpty {
            verseList = splitVerseOrder(verseOrder)
        }
        
        var verseOrderList = NSMutableArray(array: verseList)
    
        let viewController = ViewController()
        viewController.songLyrics = lyrics
        viewController.songName = songName
        viewController.verseOrderList = verseOrderList
        
        self.navigationController?.pushViewController(viewController, animated: true);
    }

    func splitVerseOrder(verseOrder: String) -> NSArray
    {
        return verseOrder.componentsSeparatedByString(" ")
    }
    
    func searchButtonItemClicked(sender:UIBarButtonItem){
       self.navigationItem.titleView = mySearchBar;
      self.navigationItem.rightBarButtonItem=nil
       mySearchBar.becomeFirstResponder()
    }
    
    func addSettingsButton ()
    {
        let image = UIImage(named: "Settings@2x.png") as UIImage!
        var settingsButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        settingsButton.addTarget(self, action: "switchToSettingsViewController:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.setImage(image, forState: .Normal)
        settingsButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        settingsButton.sizeToFit()
        var settingsBarButton:UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.setLeftBarButtonItem(settingsBarButton, animated: true)
    }
    
    func addSearchBarButton(){
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
    }
    
    func switchToSettingsViewController(sender:UIBarButtonItem){
        let settingViewController = SettingViewController(style:UITableViewStyle.Grouped)
        self.navigationController?.pushViewController(settingViewController, animated: true);
    }
    
    func showActivityIndicatory(uiView: UIView) {
        
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor.whiteColor()
        
        
        loadingView.frame = CGRectMake(0, 0, 120, 120)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.grayColor()
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        

        loadingLabel = UILabel(frame: CGRectMake(10, 45, 100, 100))
        //loadingLabel.center = CGPointMake(160, 284)
        loadingLabel.textAlignment = NSTextAlignment.Center
        loadingLabel.textColor = UIColor.whiteColor()
        loadingLabel.font = UIFont(name: "HelveticaNeue",size: 10.0)
        loadingLabel.lineBreakMode = .ByWordWrapping
        loadingLabel.numberOfLines = 0
        loadingLabel.text = "Checking update for songs database"
        self.loadingView.addSubview(loadingLabel)
        
        
        loadingActivityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        loadingActivityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        loadingActivityIndicator.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2);
        loadingView.addSubview(loadingActivityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        loadingActivityIndicator.startAnimating()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        isParentView = true
    }
}
