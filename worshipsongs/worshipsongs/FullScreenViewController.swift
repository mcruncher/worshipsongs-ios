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
    var authorName = ""
    var i = 0

    @IBOutlet var presentationView: PresentationView!
    
    
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
        analytics(name: "FullScreenViewController")
        self.onChangeOrientation(orientation: UIDevice.current.orientation)
        presentationView.songLabel.attributedText = cells[i].textLabel?.attributedText
        presentationView.songNameLabel.text = songName
        presentationView.authorLabel.text = "artist".localized + ": " + authorName
        presentationView.slideNumberLabel.text = String(1) + " of " + String(self.cells.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swipeLeft() {
        if i < cells.count - 1 {
            let labelOrginx = self.presentationView.songLabel.frame.origin.x
            self.presentationView.songLabel.attributedText = NSAttributedString(string: "")
            self.presentationView.songLabel.frame.origin.x = self.presentationView.songLabel.frame.width
            UIView.transition(with: self.presentationView.songLabel, duration: 0.1, options: .curveLinear, animations: {
                self.i = self.i + 1
                self.presentationView.songLabel.attributedText = self.cells[self.i].textLabel?.attributedText
                self.presentationView.slideNumberLabel.text = String(self.i + 1) + " of " + String(self.cells.count)
                self.presentationView.songLabel.frame.origin.x = labelOrginx
            }, completion: { _ in
            })
        }
        
    }

    func swipeRight() {
        if i > 0 {
            let labelOrginx = self.presentationView.songLabel.frame.origin.x
            self.presentationView.songLabel.attributedText = NSAttributedString(string: "")
            self.presentationView.songLabel.frame.origin.x = -self.presentationView.songLabel.frame.width
            UIView.transition(with: self.presentationView.songLabel, duration: 0.1, options: .curveLinear, animations: {
                self.i = self.i - 1
                self.presentationView.songLabel.attributedText = self.cells[self.i].textLabel?.attributedText
                self.presentationView.slideNumberLabel.text = String(self.i + 1) + " of " + String(self.cells.count)
                self.presentationView.songLabel.frame.origin.x = labelOrginx
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
