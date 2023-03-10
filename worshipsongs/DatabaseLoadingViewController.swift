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
    fileprivate let localPreferences = UserDefaults.standard
    fileprivate let databaseService = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localPreferences.set("importing.database", forKey: "import.status")
        localPreferences.synchronize()
        statusLabel.text = localPreferences.string(forKey: "import.status")?.localized
        activityController.hidesWhenStopped = true
        activityController.startAnimating()
        checkDatabase()
    }
    
    func checkDatabase() {
        statusLabel.text = localPreferences.string(forKey: "import.status")?.localized
        if isDatabaseLock() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.checkDatabase()
            }
        } else {
            if (localPreferences.string(forKey: "import.status")?.contains("error"))! {
                statusLabel.text = localPreferences.string(forKey: "import.status")?.localized
                self.activityController.stopAnimating()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
                    self.close()
                }
            } else {
                localPreferences.set("verifying.database", forKey: "import.status")
                localPreferences.synchronize()
                statusLabel.text = localPreferences.string(forKey: "import.status")?.localized
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                    if self.databaseService.verifyDatabase() {
                        self.localPreferences.set("updated.database", forKey: "import.status")
                        self.localPreferences.synchronize()
                        self.statusLabel.text = self.localPreferences.string(forKey: "import.status")?.localized
                        self.activityController.stopAnimating()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
                            self.close()
                        }
                    } else {
                        self.localPreferences.set("reverting.database", forKey: "import.status")
                        self.localPreferences.synchronize()
                        self.statusLabel.text = self.localPreferences.string(forKey: "import.status")?.localized
                        self.databaseService.revertImport()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(4 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
                            self.close()
                        }
                    }
                }
            }
        }
    }
    
    func isDatabaseLock() -> Bool {
        return localPreferences.dictionaryRepresentation().keys.contains("database.lock") && localPreferences.bool(forKey:"database.lock")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func close() {
        self.dismiss(animated: false, completion: nil)
    }

}
