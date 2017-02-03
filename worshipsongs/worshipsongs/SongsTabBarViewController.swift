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
    let presentationData = PresentationData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationData.registerForScreenNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentationData.setupScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GoToSettingView(_ sender: Any) {
        performSegue(withIdentifier: "setting", sender: self)
    }

}
