//
//  SampleViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/7/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation

import UIKit

class SampleViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tf : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
            self.view.bounds.size.width, self.view.bounds.size.height);

        var imageView = UIImageView(frame: myFrame);
        var image = UIImage(named: "Default-Portrait.png");
        imageView.image = image;
        //imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        self.view.addSubview(imageView);
        
    }
    

    
    
}