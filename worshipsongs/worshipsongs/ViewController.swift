//
//  ViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/18/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    var candies = [Candy]()
    var filteredCandies = [Candy]()
    var mySearchBar: UISearchBar!
    var tableView: UITableView!
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.navigationItem.title =  "Worship songs"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.candies = [Candy(category:"Chocolate", name:"chocolate Bar"),
            Candy(category:"Chocolate", name:"chocolate Chip"),
            Candy(category:"Chocolate", name:"dark chocolate"),
            Candy(category:"Hard", name:"lollipop"),
            Candy(category:"Hard", name:"candy cane"),
            Candy(category:"Hard", name:"jaw breaker"),
            Candy(category:"Other", name:"caramel"),
            Candy(category:"Other", name:"sour chew"),
            Candy(category:"Other", name:"gummi bear")]
        
        
        
        tableView = UITableView(frame: self.view.frame)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        var myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
            self.view.bounds.size.width, 44);
        
        mySearchBar = UISearchBar(frame: myFrame)
        mySearchBar.delegate = self;
        mySearchBar.placeholder = "Search Songs"
        //display the cancel button next to the search bar
        mySearchBar.showsCancelButton = true;
        mySearchBar.tintColor = UIColor.grayColor()
        tableView.dataSource = self
        tableView.tableHeaderView = mySearchBar
        filterContentForSearchText(mySearchBar)
        self.view.addSubview(tableView)
        
        // Reload the table
        self.tableView.reloadData()

    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //return self.candies.count
        if tableView == self.tableView && filteredCandies.count > 0{
            return self.filteredCandies.count
        } else {
            return self.candies.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var dataCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(dataCell == nil)
        {
            dataCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        
        //let candy = self.candies[indexPath.row]
        var candy : Candy
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
        self.filteredCandies = self.candies.filter({( candy: Candy) -> Bool in
            let stringMatch = candy.name.rangeOfString(searchText)
            return (stringMatch != nil)
        })
        NSLog("Matched text: \(filteredCandies).")
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("didSelectRowAtIndexPath")
    }
    
}

