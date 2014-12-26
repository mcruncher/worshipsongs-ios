//
//  ColorSettingsViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/24/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class ColorSettingsViewController: UITableViewController {
    
    var primaryLanguageColorCell: UITableViewCell = UITableViewCell()
    var secondaryLanguageColorCell: UITableViewCell = UITableViewCell()
    //let settingDataManager:SettingsDataManager = SettingsDataManager()
    
    var primaryLanguageLabel: UILabel = UILabel()
    var primaryLanguageColorLabel: UILabel = UILabel()
    var secondaryLanguageLabel: UILabel = UILabel()
    var secondaryLanguageColorLabel: UILabel = UILabel()
    
    var languageColor: UIColor = UIColor()
    
    var colorView: UIViewController = UIViewController()
   
    
    override func loadView() {
        super.loadView()
        
        // set the title
        self.title = "Color Settings"
        
        //CGRect Label1Frame = CGRectMake(10, 10, 290, 25);
        //CGRect Label2Frame = CGRectMake(10, 33, 290, 25);
        
        // construct font setting cell, section 0, row 0
        self.primaryLanguageColorCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.primaryLanguageLabel = UILabel(frame: CGRectMake(10, 10, 250, 25))
        self.primaryLanguageLabel.text = "Choose primary font color"
        self.primaryLanguageLabel.font = getFont()
        self.primaryLanguageColorCell.addSubview(self.primaryLanguageLabel)
        
        primaryLanguageColorLabel = UILabel(frame: CGRectMake(260, 15, 10, 10))
        let userSelectedPrimaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("primaryFontColor") as? NSData
        primaryLanguageColorLabel.backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedPrimaryColorData!) as? UIColor
        self.primaryLanguageColorCell.addSubview(primaryLanguageColorLabel)
        
        // construct color setting cell, section 0, row 1
        self.secondaryLanguageColorCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.secondaryLanguageLabel = UILabel(frame: CGRectMake(10, 10, 250, 25))
        self.secondaryLanguageLabel.text = "Choose secondary font color"
        self.secondaryLanguageLabel.font = getFont()
        self.secondaryLanguageColorCell.addSubview(self.secondaryLanguageLabel)
        

        secondaryLanguageColorLabel = UILabel(frame: CGRectMake(260, 15, 10, 10))
        let userSelectedSecondaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("secondaryFontColor") as? NSData
        secondaryLanguageColorLabel.backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedSecondaryColorData!) as? UIColor
        self.secondaryLanguageColorCell.addSubview(secondaryLanguageColorLabel)
        
    }
    
    // Return the number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1    // section 0 has 2 rows
        case 1: return 1    // section 1 has 1 row
        default: fatalError("Unknown number of sections")
        }
    }
    
    // Return the row for the corresponding section and row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0: return self.primaryLanguageColorCell    // section 0, row 0 is the fontSettingsCell
            default: fatalError("Unknown row in section 0")
            }
        case 1:
            switch(indexPath.row) {
            case 0: return self.secondaryLanguageColorCell // section 1, row 0 is the keepAwakeCell option
            default: fatalError("Unknown row in section 1")
            }
            
        default: fatalError("Unknown section")
        }
    }
    
    // Customize the section headings for each section
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0: return "Primary Language Color"
        case 1: return "Secondary Language Color"
        default: fatalError("Unknown section")
        }
    }
    
    // Configure the row selection code for any cells that you want to customize the row selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        if(indexPath.section == 0 && indexPath.row == 0) {
            self.colorView.view.hidden = false
            makeColorView(1)
        }
        if(indexPath.section == 1 && indexPath.row == 0) {
            self.colorView.view.hidden = false
            makeColorView(2)
        }
    }
    
    func makeColorView(var colorTag:Int){
        var buttonFrame = CGRect(x: 12, y: 100, width: 25, height: 25)
        var i:CGFloat = 1.0
        while i > 0{
            makeRainbowButtons(buttonFrame, sat: i ,bright: 1.0, colorTag: colorTag)
            i = i - 0.1
            buttonFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height
        }
        self.addChildViewController(colorView)
        self.colorView.view.alpha = 0;
        self.colorView.view.opaque = true;
        self.colorView.didMoveToParentViewController(self)
        self.colorView.view.frame = self.view.frame
        self.view.addSubview(colorView.view)
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveLinear, animations: {
            self.colorView.view.alpha = 1;
            }, completion: nil)
    }
    
    func makeRainbowButtons(buttonFrame:CGRect, sat:CGFloat, bright:CGFloat, colorTag:Int){
        var myButtonFrame = buttonFrame
        //populate an array of buttons
        for i in 0..<12{
            let hue:CGFloat = CGFloat(i) / 12.0
            let color = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: 1.0)
            let aButton = UIButton(frame: myButtonFrame)
            myButtonFrame.origin.x = myButtonFrame.size.width + myButtonFrame.origin.x
            aButton.backgroundColor = color
            aButton.tag = colorTag
            colorView.view.addSubview(aButton)
            aButton.addTarget(self, action: "displayColor:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func displayColor(sender:UIButton){
        var r:CGFloat = 0,g:CGFloat = 0,b:CGFloat = 0
        var a:CGFloat = 0
        var h:CGFloat = 0,s:CGFloat = 0,l:CGFloat = 0
        let color = sender.backgroundColor!
        if color.getHue(&h, saturation: &s, brightness: &l, alpha: &a){
            if color.getRed(&r, green: &g, blue: &b, alpha: &a){
                var colorText = NSString(format: "HSB: %4.2f,%4.2f,%4.2f RGB: %4.2f,%4.2f,%4.2f",
                    Float(h),Float(s),Float(b),Float(r),Float(g),Float(b))
                languageColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
                let tagValue = sender.tag
                let data = NSKeyedArchiver.archivedDataWithRootObject(languageColor)
                if(tagValue == 1)
                {
                    
                    SettingsDataManager.sharedInstance.saveData(data, key: "primaryFontColor")
                    let userSelectedPrimaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("primaryFontColor") as? NSData
                    primaryLanguageColorLabel.backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedPrimaryColorData!) as? UIColor
                }
                else
                {
                    SettingsDataManager.sharedInstance.saveData(data, key: "secondaryFontColor")
                    let userSelectedSecondaryColorData  =  NSUserDefaults.standardUserDefaults().objectForKey("secondaryFontColor") as? NSData
                    secondaryLanguageColorLabel.backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedSecondaryColorData!) as? UIColor
                }
                self.colorView.view.hidden = true
                
            }
        }
        
    }
    
    func getFont() -> UIFont{
        return UIFont(name: "HelveticaNeue", size: CGFloat(12))!
    }
}