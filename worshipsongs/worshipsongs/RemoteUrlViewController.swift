//
//  RemoteUrlViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 24/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class RemoteUrlViewController: UIViewController {

    @IBOutlet weak var remoteUrl: UITextView!
    fileprivate let preferences = UserDefaults.standard
    fileprivate let databaseService = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.remoteUrl.layer.cornerRadius = 10
        self.remoteUrl.clipsToBounds = true
        remoteUrl.text = self.preferences.string(forKey: "remote.url")!
        remoteUrl.becomeFirstResponder()
        remoteUrl.isScrollEnabled = true
        self.title = "enterRemoteUrl".localized
        let backButton = UIBarButtonItem(title: "load".localized, style: .plain, target: self, action: #selector(RemoteUrlViewController.doneLoading))
        navigationItem.rightBarButtonItem = backButton
    }
    
    func doneLoading() {
        if !remoteUrl.text!.isEmpty && (remoteUrl.text?.contains(".sqlite") )!{
            self.preferences.setValue(remoteUrl.text, forKey: "remote.url")
            self.preferences.synchronize()
            databaseService.importDatabase(url: NSURL(string: remoteUrl.text!)! as URL)
            self.navigationController!.popToRootViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "invalid.file".localized, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
