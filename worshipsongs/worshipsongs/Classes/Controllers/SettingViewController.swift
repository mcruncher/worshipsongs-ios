//
//  SettingViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/23/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UITableViewController {
    
    var fontName: String = SettingsDataManager.sharedInstance.getFontName
    let settingDataManager:SettingsDataManager = SettingsDataManager()
    var fontSettingsCell: UITableViewCell = UITableViewCell()
    var colorSettingsCell: UITableViewCell = UITableViewCell()
    var keepAwakeCell: UITableViewCell = UITableViewCell()
    var restoreSettingCell: UITableViewCell = UITableViewCell()
    var fontSizeSliderCell: UITableViewCell = UITableViewCell()
    
    var fontSettingsLabel: UILabel = UILabel()
    var colorSettingsLabel: UILabel = UILabel()
    
    var restoreSettingButton: UIButton = UIButton()
    
    var fontSizeSlider: UISlider = UISlider()
    
    override func loadView() {
        super.loadView()
        
        // set the title
        self.title = "Settings"
        //println("fontName : \(fontName)")
        
        // construct font setting cell, section 0, row 0
        self.fontSettingsCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.fontSettingsLabel = UILabel(frame: CGRectInset(self.fontSettingsCell.contentView.bounds, 15, 0))
        self.fontSettingsLabel.text = "Font settings"
        self.fontSettingsLabel.font = getFont()
        self.fontSettingsCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.fontSettingsCell.addSubview(self.fontSettingsLabel)
        
        // construct color setting cell, section 0, row 1
        self.colorSettingsCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.colorSettingsLabel = UILabel(frame: CGRectInset(self.colorSettingsCell.contentView.bounds, 15, 0))
        self.colorSettingsLabel.text = "Color settings"
        self.colorSettingsLabel.font = getFont()
        self.colorSettingsCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.colorSettingsCell.addSubview(self.colorSettingsLabel)
        
        // construct share cell, section 1, row 0
        self.keepAwakeCell.textLabel?.text = "To keep awake on screen"
        self.keepAwakeCell.textLabel?.font=getFont()
        self.keepAwakeCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        setKeepAwakeStatus()
        
        // construct color setting cell, section 2, row 0
        self.restoreSettingCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.restoreSettingButton = UIButton(frame: CGRectMake(0, 5, 10, 10))
        self.restoreSettingButton.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.TouchUpInside)
        self.restoreSettingButton.setTitle("Restore default values", forState: UIControlState.Normal)
        self.restoreSettingButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.restoreSettingButton.sizeToFit()
        self.restoreSettingButton.titleLabel?.font = getFont()
        self.restoreSettingCell.addSubview(self.restoreSettingButton)
        
        self.fontSizeSliderCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.fontSizeSlider = UISlider(frame: CGRectInset(self.fontSizeSliderCell.contentView.bounds, 50, 10))
        self.fontSizeSlider.maximumValue = 100;
        self.fontSizeSlider.minimumValue = 1;
        self.fontSizeSlider.continuous = true;
      // self.fontSizeSlider.
        self.fontSizeSlider.addTarget(self, action: "sliderChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.fontSizeSliderCell.addSubview(self.fontSizeSlider)

    }
    
    // Return the number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 2    // section 0 has 2 rows
        case 1: return 1    // section 1 has 1 row
        case 2: return 1    // section 2 has 1 row
        default: fatalError("Unknown number of sections")
        }
    }
    
    // Return the row for the corresponding section and row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0: return self.fontSettingsCell    // section 0, row 0 is the fontSettingsCell
            case 1: return self.colorSettingsCell   // section 0, row 1 is the colorSettingsCell
            case 2: return self.restoreSettingCell  // section 0, row 1 is the restoreSettingCell
            default: fatalError("Unknown row in section 0")
            }
        case 1:
            switch(indexPath.row) {
            case 0: return self.keepAwakeCell // section 1, row 0 is the keepAwakeCell option
            default: fatalError("Unknown row in section 1")
            }
        case 2:
            switch(indexPath.row) {
            case 0: return self.restoreSettingCell // section 2, row 0 is the restoreSettingCell option
            default: fatalError("Unknown row in section 0")
            }
            
            
        default: fatalError("Unknown section")
        }
    }
    
    // Customize the section headings for each section
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0: return "Appearence"
        case 1: return "Accessiblity"
        case 2: return "Restore"
        default: fatalError("Unknown section")
        }
    }
    
    // Configure the row selection code for any cells that you want to customize the row selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.section == 0 && indexPath.row == 0) {
            let fontSettingViewController = FontSettingsViewController(style:UITableViewStyle.Grouped)
            self.navigationController?.pushViewController(fontSettingViewController, animated: true);
        }
        
        if(indexPath.section == 0 && indexPath.row == 1) {
            let colorSettingViewController = ColorSettingsViewController(style:UITableViewStyle.Grouped)
            self.navigationController?.pushViewController(colorSettingViewController, animated: true);
        }
        
        
        // Handle social cell selection to toggle checkmark
        if(indexPath.section == 1 && indexPath.row == 0) {
            
            // deselect row
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            // toggle check mark
            if(self.keepAwakeCell.accessoryType == UITableViewCellAccessoryType.None) {
                self.keepAwakeCell.accessoryType = UITableViewCellAccessoryType.Checkmark;
                SettingsDataManager.sharedInstance.saveData(true, key: "keepAwake")
            } else {
                self.keepAwakeCell.accessoryType = UITableViewCellAccessoryType.None;
                SettingsDataManager.sharedInstance.saveData(false, key: "keepAwake")
            }
        }
        
        if(indexPath.section == 2 && indexPath.row == 0) {
            SettingsDataManager.sharedInstance.reset()
        }
    }
    
    func sliderChanged(sender:UISlider){
        println("Setting value reset")
        SettingsDataManager.sharedInstance.reset()
        setKeepAwakeStatus()
    }
    
    func getFont() -> UIFont{
        return UIFont(name: "HelveticaNeue", size: CGFloat(12))!
    }
    
    func setKeepAwakeStatus()
    {
        var keepAwakeStatus: Bool = settingDataManager.getKeepAwake
        if(keepAwakeStatus == true){
            self.keepAwakeCell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else{
            self.keepAwakeCell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
}