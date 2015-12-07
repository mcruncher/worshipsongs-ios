//
//  AbstractViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 07/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class AbstractViewController: UITableViewController, UISearchBarDelegate  {
    
     var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchButtonItemClicked(sender:UIBarButtonItem){
        self.tabBarController?.navigationItem.titleView = searchBar;
        self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = false
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func hideSearchBar() {
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = true
        self.searchBar.text = ""
        self.tabBarController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonItemClicked:"), animated: true)
    }

}
