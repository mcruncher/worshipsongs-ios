//
//  ViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/18/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UITableViewDataSource {
    
    var candies = [DataModel]()
    var filteredCandies = [DataModel]()
    var dataValue = [DataModel]()
    
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        dataValue = candies
//        tableView = UITableView(frame: self.view.frame, style:UITableViewStyle.Grouped)
//        tableView.backgroundView = nil
//        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
//        
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        // Reload the table
        self.tableView.reloadData()

    }
    
    override func tableView(tableView: UITableView,heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0){
        return 1.0;
        }
        return 32.0;
    }
        
    override func tableView(tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.25;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        NSLog("Candies value: \(self.candies.count).")
        return self.candies.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var dataCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(dataCell == nil)
        {
            dataCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        // get the items in this section
        let sectionItems = self.candies[indexPath.section]
        NSLog("sectionItems value: \(sectionItems.name).")
       

        
        //let candy = self.candies[indexPath.row]
        dataCell!.textLabel!.text = sectionItems.name
        
        return dataCell!
    }
    
    
    
    
    
}

