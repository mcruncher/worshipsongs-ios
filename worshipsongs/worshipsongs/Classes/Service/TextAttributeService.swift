//
//  TextAttributeService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation
import UIKit

class TextAttributeService{

    func getDefaultFont() -> UIFont{
        return UIFont(name: "HelveticaNeue", size: CGFloat(14))!
    }

    func getDefaultTextAttributes() -> NSDictionary{
        let textFontAttributes = [ NSFontAttributeName: getDefaultFont(),NSForegroundColorAttributeName: UIColor.blackColor()]
        return textFontAttributes
    }
    
     func getDefaultNavigatioItemFontColor() -> NSDictionary{
        let titleForeGroundColor: NSDictionary = [NSForegroundColorAttributeName: UIColor.blackColor()]
        return titleForeGroundColor
    }

}
