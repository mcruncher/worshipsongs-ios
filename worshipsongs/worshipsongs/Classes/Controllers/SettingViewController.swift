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
    
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    let textAttributeService:TextAttributeService = TextAttributeService()
    let settingDataManager:SettingsDataManager = SettingsDataManager()
    let util:Util = Util()
    
    var fontSettingsCell: UITableViewCell = UITableViewCell()
    var colorSettingsCell: UITableViewCell = UITableViewCell()
    var keepAwakeCell: UITableViewCell = UITableViewCell()
    var restoreSettingCell: UITableViewCell = UITableViewCell()
    var aboutSettingCell: UITableViewCell = UITableViewCell()
    var versionSettingCell: UITableViewCell = UITableViewCell()
    
    
    var fontSettingsLabel: UILabel = UILabel()
    var colorSettingsLabel: UILabel = UILabel()
    var restoreSettingButton: UIButton = UIButton()
    var aboutSettingButton: UIButton = UIButton()
    var versionLabel: UILabel = UILabel()
    var versionValueLabel: UILabel = UILabel()
    
    
    override func loadView() {
        super.loadView()
        
        // set the title
        self.title = "Settings"
        //println("fontName : \(fontName)")
        var fontImageView = UIImageView(frame: CGRectMake(5,13, 20, 20));
        // construct font setting cell, section 0, row 0
        self.fontSettingsCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.fontSettingsLabel = UILabel(frame: CGRectInset(self.fontSettingsCell.contentView.bounds, 30, 0))
        self.fontSettingsLabel.text = "Font settings"
        self.fontSettingsLabel.font = textAttributeService.getDefaultFont()
        self.fontSettingsCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        var fontImage = UIImage(named: "Font-icon.png");
        fontImageView.image = fontImage;
        self.fontSettingsCell.addSubview(fontImageView)
        self.fontSettingsCell.addSubview(self.fontSettingsLabel)
        
        // construct color setting cell, section 0, row 1
         var colorImageView = UIImageView(frame: CGRectMake(5,13, 20, 20));
        self.colorSettingsCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.colorSettingsLabel = UILabel(frame: CGRectInset(self.colorSettingsCell.contentView.bounds, 30, 0))
        self.colorSettingsLabel.text = "Color settings"
        self.colorSettingsLabel.font = textAttributeService.getDefaultFont()
        self.colorSettingsCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        var colorImage = UIImage(named: "color.png");
        colorImageView.image = colorImage;
        self.colorSettingsCell.addSubview(colorImageView)
        self.colorSettingsCell.addSubview(self.colorSettingsLabel)
        
        // construct share cell, section 1, row 0
        self.keepAwakeCell.textLabel?.text = "To keep awake on screen"
        self.keepAwakeCell.textLabel?.font = textAttributeService.getDefaultFont()
        self.keepAwakeCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        setKeepAwakeStatus()
        
        // construct color setting cell, section 2, row 0
        self.restoreSettingCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.restoreSettingButton = UIButton(frame: CGRectMake(0, 5, 10, 10))
        self.restoreSettingButton.addTarget(self, action: "resetValue:", forControlEvents: UIControlEvents.TouchUpInside)
        self.restoreSettingButton.setTitle("Restore default values", forState: UIControlState.Normal)
        self.restoreSettingButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.restoreSettingButton.sizeToFit()
        self.restoreSettingButton.titleLabel?.font = textAttributeService.getDefaultFont()
        self.restoreSettingCell.addSubview(self.restoreSettingButton)
        
        
        // construct color setting cell, section 3, row 0
        self.versionSettingCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.versionLabel = UILabel(frame: CGRectMake(5, 10, 70, 20))
        self.versionLabel.text = "Version"
        self.versionLabel.textAlignment = NSTextAlignment.Left;
        self.versionLabel.font = textAttributeService.getDefaultFont()
        
        self.versionValueLabel = UILabel(frame: CGRectMake(0, 5, 10, 10))
        self.versionValueLabel.text = "version"
        self.versionLabel.textAlignment = NSTextAlignment.Right;
        self.versionValueLabel.textColor = UIColor.grayColor()
        
       // self.versionValueLabel.lineBreakMode = ;
        self.versionValueLabel.numberOfLines = 0;
        self.versionValueLabel.font = textAttributeService.getDefaultFont()
         self.versionValueLabel.textAlignment = NSTextAlignment.Right;
        //self.versionSettingCell.addSubview(self.versionLabel)
       // self.versionSettingCell.addSubview(self.versionValueLabel)
        self.versionSettingCell.contentView.addSubview(self.versionLabel)
        self.versionSettingCell.contentView.addSubview(self.versionValueLabel)
        
        self.aboutSettingCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.aboutSettingButton = UIButton(frame: CGRectMake(10, 5, 10, 10))
        self.aboutSettingButton.addTarget(self, action: "goAbout:", forControlEvents: UIControlEvents.TouchUpInside)
        self.aboutSettingButton.setTitle("About", forState: UIControlState.Normal)
        self.aboutSettingButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.aboutSettingButton.sizeToFit()
        self.aboutSettingButton.titleLabel?.font = textAttributeService.getDefaultFont()
        self.aboutSettingCell.addSubview(self.aboutSettingButton)
        
        

    }
    
    // Return the number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 2    // section 0 has 2 rows
        case 1: return 1    // section 1 has 1 row
        case 2: return 1    // section 2 has 1 row
        case 3: return 2
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
        case 3:
            switch(indexPath.row) {
            case 0: return self.aboutSettingCell // section 2, row 0 is the restoreSettingCell option
            case 1:
                var dataCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
                if(dataCell == nil)
                {
                    dataCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL_ID")
                }
                dataCell?.textLabel?.text="Version"
                dataCell?.detailTextLabel?.text = util.getVersionNumber()
                dataCell?.detailTextLabel?.numberOfLines=0
                dataCell!.textLabel?.font = textAttributeService.getDefaultFont()
                dataCell!.detailTextLabel?.font = textAttributeService.getDefaultFont()
                dataCell?.selectionStyle = UITableViewCellSelectionStyle.None;
                return dataCell! // section 2, row 0 is the restoreSettingCell option
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
        case 3: return "General"
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
        
        if(indexPath.section == 3 && indexPath.row == 0) {
            let aboutViewController = AboutViewController()
            self.navigationController?.pushViewController(aboutViewController, animated: true);
        }
    }
    
    func resetValue(sender:UIButton){
        let alertView = UIAlertController(title: "Alert!", message: "Reset all default settings", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (alertAction) -> Void in
            SettingsDataManager.sharedInstance.reset()
            self.setKeepAwakeStatus()
        }))
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
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
    
    func goAbout(sender:UIButton){
        let aboutViewController = AboutViewController()
        self.navigationController?.pushViewController(aboutViewController, animated: true);
    }
    
    func resizeImage(image : UIImage, pixelValue: Int) -> UIImage
    {
        var newSize:CGSize = CGSize(width: pixelValue,height: pixelValue)
        let rect = CGRectMake(0,0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        // image is a variable of type UIImage
        image.drawInRect(rect)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}