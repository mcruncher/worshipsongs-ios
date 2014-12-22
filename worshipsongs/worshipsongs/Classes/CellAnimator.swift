//
//  CellAnimator.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/22/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import Foundation

import UIKit

class CellAnimator {
    // placeholder for things to come -- only fades in for now
    class func animate(cell:UITableViewCell) {
        let view = cell.contentView
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPointMake(-20, -20)
        var startTransform = CATransform3DIdentity // 2
        startTransform = CATransform3DRotate(CATransform3DIdentity,
            rotationRadians, 0.0, 0.0, 1.0) // 3
        startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0) // 4
        
        // 5
        view.layer.transform = startTransform
        view.layer.opacity = 0.8
        
        // 6
        UIView.animateWithDuration(0.4) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
}
