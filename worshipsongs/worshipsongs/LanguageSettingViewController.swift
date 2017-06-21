//
//  LanguageSettingViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 20/06/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class LanguageSettingViewController: UIViewController {

    fileprivate let preferences = UserDefaults.standard
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var tamilButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tamilButton.setTitle("tamil".localized, for: .normal)
        englishButton.setTitle("english".localized, for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickEnglish(_ sender: Any) {
        self.preferences.setValue("english", forKey: "language")
        self.preferences.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
        self.dismiss(animated: false, completion: nil)
        
    }

    @IBAction func onClickTamil(_ sender: Any) {
        self.preferences.setValue("tamil", forKey: "language")
        self.preferences.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
        self.dismiss(animated: false, completion: nil)
    }
}
