//
//  ColorPaletteView.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/24/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore



class ColorPaletteView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var colorsArray: [(UIColor, UIColor)] = [(UIColor, UIColor)]()

    var arrayColors: NSMutableArray = NSMutableArray()
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 25, height: 20)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
    
        
        
        
        initArray()
        
       self.view.addSubview(collectionView!)
    }
    
    
    
    func initArray()
    {
        // Get colorPalette array from plist file
        var colorPalette: Array<String> = Array()
        
        let path = NSBundle.mainBundle().pathForResource("colorPalette", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path!)
        if let colorPalettePlistFile = pListArray {
            colorPalette = colorPalettePlistFile as [String]
        }
        for(var i=0; i<colorPalette.count; i++){
            arrayColors.addObject(hexStringToUIColor(colorPalette[i]))
        }
    }
    
    
    
     func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 2.0
        cell.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as UICollectionViewCell
        
        var textLabel = UILabel(frame: CGRectMake(0, 0, cell.frame.size.width,cell.frame.size.height))
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.backgroundColor = arrayColors[indexPath.row] as? UIColor
        cell.contentView.addSubview(textLabel)
        
        return cell
    }
    
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
//        
//        let cell: CustomCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as CustomCollectionViewCell
//        
//        let attributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
//        let attributesFrame = attributes?.frame
//        let frameToOpenFrom = collectionView.convertRect(attributesFrame!, toView: collectionView.superview)
//        transitionDelegate.openingFrame = frameToOpenFrom
//        
//        let detailViewController = DetailViewController()
//        detailViewController.colorArray = cell.gradientLayer?.colors
//        detailViewController.transitioningDelegate = transitionDelegate
//        detailViewController.modalPresentationStyle = .Custom
//        presentViewController(detailViewController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayColors.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
    }
    
    
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (countElements(cString) != 6) {
        //    return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}