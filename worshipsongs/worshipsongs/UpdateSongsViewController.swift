//
//  UpdateSongsViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 02/08/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class UpdateSongsViewController: UIViewController {
    
    @IBOutlet weak var activityController: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    fileprivate let preferences = UserDefaults.standard
    fileprivate let databaseService = DatabaseService()
    let restApiService: RestApiService = RestApiService()
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateSongsViewController.revertUpdate(_:)), name: NSNotification.Name(rawValue: "revertUpdate"), object: nil)
        preferences.setValue("updating.songs", forKey: "update.status")
        preferences.synchronize()
        statusLabel.text = "update.checking".localized
        activityController.hidesWhenStopped = true
        activityController.startAnimating()
        updateButton.setTitle("yes".localized, for: .normal)
        updateButton.layer.cornerRadius = 5
        cancelButton.setTitle("no".localized, for: .normal)
        cancelButton.layer.cornerRadius = 5
        closeButton.setTitle("ok".localized, for: .normal)
        closeButton.layer.cornerRadius = 5
        updateButton.isHidden = true
        cancelButton.isHidden = true
        closeButton.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateSongs()
    }
    
    func updateSongs() {
       
        let url = preferences.string(forKey: "check.update.url")
        if(restApiService.checkUpdate(URL(string: url!)!)) {
            self.activityController.stopAnimating()
            self.statusLabel.text = "update.avaliable".localized
            updateButton.isHidden = false
            cancelButton.isHidden = false
            closeButton.isHidden = true
        } else {
            self.statusLabel.text = "update.uptodate".localized
            self.activityController.stopAnimating()
            closeButton.isHidden = false
        }
    }
    
    @IBAction func update(_ sender: Any) {
        updateButton.isHidden = true
        cancelButton.isHidden = true
        closeButton.isHidden = true
        activityController.startAnimating()
        statusLabel.text = "updating.songs".localized
        self.databaseService.updateDatabase(url: NSURL(string: preferences.string(forKey:"update.url")!)! as URL)
        checkDatabase()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.activityController.stopAnimating()
        self.close()
    }
    
    @IBOutlet weak var cancel: UIButton!
    
    func revertUpdate(_ nsNotification: NSNotification) {
        databaseService.revertImport()
    }
    
    func checkDatabase() {
        statusLabel.text = preferences.string(forKey: "update.status")?.localized
        if isDatabaseLock() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.checkDatabase()
            }
        } else {
            if (preferences.string(forKey: "update.status")?.contains("error"))! {
                statusLabel.text = preferences.string(forKey: "update.status")?.localized
                self.activityController.stopAnimating()
                self.close()
            } else {
                self.preferences.setValue(restApiService.sha, forKey: "sha")
                self.preferences.setValue("Songs updated", forKey: "import.status")
                self.preferences.synchronize()
                self.statusLabel.text = self.preferences.string(forKey: "import.status")?.localized
                self.activityController.stopAnimating()
                closeButton.isHidden = false
            }
        }
    }
    
    func isDatabaseLock() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("update.lock") && preferences.bool(forKey:"update.lock")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func close() {
        self.dismiss(animated: false, completion: nil)
    }
    
}
