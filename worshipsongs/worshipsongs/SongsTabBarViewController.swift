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
    var presentationData = PresentationData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.onBeforeUpdateDatabase(_:)), name: NSNotification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.onAfterUpdateDatabase(_:)), name: NSNotification.Name(rawValue: "onAfterUpdateDatabase"), object: nil)
    }
    
    func onBeforeUpdateDatabase(_ nsNotification: NSNotification) {
        if isDatabaseLock() {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "loading") as? DatabaseLoadingViewController
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
    }
    
    func isDatabaseLock() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("database.lock") && preferences.bool(forKey:"database.lock")
    }

    func onAfterUpdateDatabase(_ nsNotification: NSNotification) {
        self.selectedViewController?.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentationData = PresentationData()
        presentationData.setupScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func GoToSettingView(_ sender: Any) {
        performSegue(withIdentifier: "setting", sender: self)
    }

}
