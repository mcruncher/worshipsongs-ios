//
//  CategoriesTableViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 31/03/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController   {
    
    var categoryModel = [Category]()
    var categoryName: String = ""
    var filteredCategoryModel = [Category]()
    var databaseHelper = DatabaseHelper()
    var songsModel = [Songs]()
    var verseList: NSArray = NSArray()
    var songLyrics: NSString = NSString()
    var songName: String = ""
    
    var searchBar: UISearchBar!
    var refresh = UIRefreshControl()
    fileprivate var songTabBarController: SongsTabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTabBarController = self.tabBarController as? SongsTabBarViewController
        self.tabBarItem.title = "categories".localized
        tableView.contentInset = UIEdgeInsetsMake(0, 0, (self.tabBarController?.tabBar.frame.height)!, 0)
        //refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(CategoriesTableViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let songTabBarController = tabBarController as! SongsTabBarViewController
        songTabBarController.navigationItem.title = "categories".localized
        categoryModel = databaseHelper.getCategoryModel()
        filteredCategoryModel = categoryModel
        createSearchBar()
        tableView.reloadData()
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
        return filteredCategoryModel.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredCategoryModel[(indexPath as NSIndexPath).row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        hideSearchBar()
        categoryName = filteredCategoryModel[(indexPath as NSIndexPath).row].name
        songsModel = databaseHelper.getCategorySongsModel(filteredCategoryModel[(indexPath as NSIndexPath).row].id)
        performSegue(withIdentifier: "artistTitle", sender: self)
        
    }
    
    func splitVerseOrder(_ verseOrder: String) -> NSArray
    {
        return verseOrder.components(separatedBy: " ") as NSArray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "artistTitle") {
            let titleTableViewController = segue.destination as! ArtistSongsTitleTableViewController
            titleTableViewController.artistName = categoryName
            titleTableViewController.songModel = songsModel
            titleTableViewController.songTabBarController = songTabBarController
        }
    }
    
    
    
    func refresh(_ sender:AnyObject)
    {
        filteredCategoryModel = categoryModel
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
}

extension CategoriesTableViewController: UISearchBarDelegate {
    
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
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistsTableViewController.searchButtonItemClicked(_:))), animated: true)
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
        self.tabBarController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ArtistsTableViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(self.searchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchBar: UISearchBar) {
        // Filter the array using the filter method
        let searchText = searchBar.text
        var data = categoryModel
        if (searchText?.characters.count)! > 0 {
            data = self.categoryModel.filter({( category: Category) -> Bool in
                let stringMatch = (category.name as NSString).localizedCaseInsensitiveContains(searchText!)
                return (stringMatch)
            })
        }
        self.filteredCategoryModel = data
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        hideSearchBar()
        filteredCategoryModel = categoryModel
        tableView.reloadData()
    }
}
