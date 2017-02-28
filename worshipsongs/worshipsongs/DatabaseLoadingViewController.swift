//
//  DatabaseLoadingViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 27/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class DatabaseLoadingViewController: UIViewController {

    
    @IBOutlet weak var activityController: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    fileprivate let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferences.setValue("importing.database", forKey: "import.status")
        preferences.synchronize()
        statusLabel.text = preferences.string(forKey: "import.status")?.localized
        activityController.hidesWhenStopped = true
        activityController.startAnimating()
        checkDatabase()
    }
    
    func checkDatabase() {
        statusLabel.text = preferences.string(forKey: "import.status")?.localized
        if isDatabaseLock() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.checkDatabase()
            }
        } else {
            activityController.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "onAfterUpdateDatabase"), object: nil,  userInfo: nil)
                self.close()
            }
        }
    }
    
    func isDatabaseLock() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("database.lock") && preferences.bool(forKey:"database.lock")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func close() {
        self.dismiss(animated: false, completion: nil)
    }

}
