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
    
    var candies = [DataModel]()
    var filteredCandies = [DataModel]()
    
    var dataCell: UITableViewCell?
    
    var mySearchBar: UISearchBar!
    var value = [Int]()
    
            
    override func viewDidLoad() {
        
        var path = Util.getPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        println("path : \(path)")
        
        // Sample Data for candyArray
        self.candies = [DataModel(category:"Chocolate", name:"chocolate Bar"),
            DataModel(category:"Chocolate", name:"chocolate Chip"),
            DataModel(category:"Chocolate", name:"dark chocolate"),
            DataModel(category:"Hard", name:"lollipop"),
            DataModel(category:"Hard", name:"candy cane"),
            DataModel(category:"Hard", name:"jaw breaker"),
            DataModel(category:"Other", name:"caramel"),
            DataModel(category:"Other", name:"sour chew"),
            DataModel(category:"Other", name:"gummi bear")]
        
        self.navigationItem.title = "Worship songs"
//        var homeButton : UIBarButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: "")
//        self.navigationItem.rightBarButtonItem = homeButton
        
        var myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
            self.view.bounds.size.width, 44);
        
        mySearchBar = UISearchBar(frame: myFrame)
    
        mySearchBar.delegate = self;
        mySearchBar.placeholder = "Search Songs"
        //display the cancel button next to the search bar
        mySearchBar.showsCancelButton = false;
        
        mySearchBar.tintColor = UIColor.grayColor()
        tableView.dataSource = self
        self.tableView.tableHeaderView = mySearchBar;
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    
    
    // Return the number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return self.candies.count
        if tableView == self.tableView && filteredCandies.count > 0{
            return self.filteredCandies.count
        } else {
            return self.candies.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        var dataCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(dataCell == nil)
        {
            dataCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        //let candy = self.candies[indexPath.row]
        //let candy = self.candies[indexPath.row]
        var candy : DataModel
        // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
        if tableView == self.tableView && filteredCandies.count > 0 {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        dataCell!.textLabel!.text = candy.name
        
        return dataCell!
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        filterContentForSearchText(mySearchBar)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(mySearchBar)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchBar: UISearchBar) {
        // Filter the array using the filter method
        var searchText = searchBar.text
        NSLog("Search bar text: \(searchText).")
        self.filteredCandies = self.candies.filter({( candy: DataModel) -> Bool in
            let stringMatch = candy.name.rangeOfString(searchText)
            return (stringMatch != nil)
        })
        NSLog("Matched text: \(filteredCandies).")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("didSelectRowAtIndexPath")
        var welcomeMessage: String
        let viewController = ViewController()
        viewController.candies = candies
       // viewController.candies = candies
        self.navigationController?.presentViewController(viewController, animated: true, completion: nil)
    }

    
}
