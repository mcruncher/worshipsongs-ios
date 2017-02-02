//
//  SongsTabBarViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 07/12/2015.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class SongsTabBarViewController: UITabBarController{
    
    var secondWindow: UIWindow?
    fileprivate let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForScreenNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GoToSettingView(_ sender: Any) {
        performSegue(withIdentifier: "setting", sender: self)
    }
    
    func registerForScreenNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SongWithVideoViewController.setupScreen), name: NSNotification.Name.UIScreenDidConnect, object: nil)
    }
    
    func setupScreen() {
        if UIScreen.screens.count > 1 {
            let secondScreen = UIScreen.screens[1]
            secondWindow = UIWindow(frame: secondScreen.bounds)
            secondWindow?.screen = secondScreen
            let secondScreenView = UIView(frame: (secondWindow?.frame)!)
            secondWindow?.addSubview(secondScreenView)
            secondWindow?.isHidden = false
            secondScreenView.backgroundColor = UIColor.white
            if isPresentationStringNotEmpty() {
                let externalLabel = UILabel()
                externalLabel.textAlignment = NSTextAlignment.center
                externalLabel.font = UIFont(name: "Helvetica", size: 50.0)
                externalLabel.frame = (secondScreenView.bounds)
                externalLabel.numberOfLines = 0
                externalLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                
                let presentationText = self.preferences.string(forKey: "presentationString")
                let customTextSettingService: CustomTextSettingService = CustomTextSettingService()
                externalLabel.attributedText = customTextSettingService.getAttributedString(NSString(string:presentationText!))
                secondScreenView.addSubview(externalLabel)
            } else {
                let imageView = UIImageView(image: #imageLiteral(resourceName: "Default-Landscape"))
                imageView.frame = (secondScreenView.bounds)
                secondScreenView.addSubview(imageView)
            }
        }
    }
    
    fileprivate func isPresentationStringNotEmpty() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("presentationString") && self.preferences.string(forKey: "presentationString") != " "
    }

}
