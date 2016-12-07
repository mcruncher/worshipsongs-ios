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
    var songName: String = ""
    var i = 0

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
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
        titleLabel.text = songName
        cellLabel.font = cells[i].textLabel?.font
        cellLabel.attributedText = cells[i].textLabel?.attributedText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swipeLeft() {
        if i < cells.count - 1 {
            let labelOrginx = self.cellLabel.frame.origin.x
            self.cellLabel.attributedText = NSAttributedString(string: "")
            self.cellLabel.frame.origin.x = self.cellLabel.frame.width
            UIView.transition(with: self.cellLabel, duration: 0.1, options: .curveLinear, animations: {
                self.i = self.i + 1
                self.cellLabel.attributedText = self.cells[self.i].textLabel?.attributedText
                self.cellLabel.frame.origin.x = labelOrginx
            }, completion: { _ in
            })
        }
        
    }

    func swipeRight() {
        if i > 0 {
            let labelOrginx = self.cellLabel.frame.origin.x
            self.cellLabel.attributedText = NSAttributedString(string: "")
            self.cellLabel.frame.origin.x = -self.cellLabel.frame.width
            UIView.transition(with: self.cellLabel, duration: 0.1, options: .curveLinear, animations: {
                self.i = self.i - 1
                self.cellLabel.attributedText = self.cells[self.i].textLabel?.attributedText
                self.cellLabel.frame.origin.x = labelOrginx
            }, completion: { _ in
            })
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.onChangeOrientation(orientation: UIDevice.current.orientation)
    }
    
    func onChangeOrientation(orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.navigationBar.tintColor = UIColor.gray
            back()
        case .landscapeRight:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        case .landscapeLeft:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        default:
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.navigationBar.tintColor = UIColor.gray
            back()
        }
    }
    
    func back() {
        let transition = CATransition()
        transition.duration = 0.75
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController!.view.layer.add(transition, forKey: nil)
        _ = navigationController?.popViewController(animated: false)
    }

}
