//
//  FullScreenViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 16/11/2016.
//  Copyright © 2016 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    var cells = [UITableViewCell]()
    var i = 0

    @IBOutlet weak var cellLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(FullScreenViewController.swipeRight))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(FullScreenViewController.swipeLeft))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.onChangeOrientation(orientation: UIDevice.current.orientation)
        cellLabel.attributedText = cells[i].textLabel?.attributedText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swipeLeft() {
        if i < cells.count - 1 {
           i = i + 1
           cellLabel.attributedText = cells[i].textLabel?.attributedText
        }
        
    }

    func swipeRight() {
        if i > 0 {
            i = i - 1
            cellLabel.attributedText = cells[i].textLabel?.attributedText
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.onChangeOrientation(orientation: UIDevice.current.orientation)
    }
    
    func onChangeOrientation(orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            _ = navigationController?.popViewController(animated: true)
        case .landscapeRight:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        case .landscapeLeft:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        default:
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            _ = navigationController?.popViewController(animated: true)
        }
    }

}
