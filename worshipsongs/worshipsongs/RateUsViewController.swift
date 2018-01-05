//
//  RateUsViewController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 05/01/2018.
//  Copyright © 2018 Vignesh Palanisamy. All rights reserved.
//

import UIKit
import StoreKit

class RateUsViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rateUsLabel: UILabel!
    @IBOutlet weak var shareAppLabel: UILabel!
    @IBOutlet weak var remindMeLaterButton: UIButton!
    fileprivate let preferences = UserDefaults.standard
    var remindMe = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "message_rateUs".localized
        rateUsLabel.text =  "rateUs".localized
        shareAppLabel.text = "shareApp".localized
        remindMeLaterButton.setTitle("remindMeLater".localized, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rateApp(_ sender: Any) {
        rateUs()
        remindMe = 90
        remindMeLaterButton.setTitle("done".localized, for: .normal)
    }
    
    @IBAction func shareApp(_ sender: Any) {
        shareThisApp()
        remindMeLaterButton.setTitle("done".localized, for: .normal)
    }
    
    @IBAction func remindMeLater(_ sender: Any) {
        updateNextReminder(remindMe > 0 ? remindMe : 10)
        self.dismiss(animated: false, completion: nil)
    }
    
    func rateUs() {
        if #available(iOS 10.3, *), (remindMe == 0) {
            SKStoreReviewController.requestReview()
        } else {
            rateApp() { success in
                self.updateNextReminder(30)
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func updateNextReminder(_ interval: Int) {
        let calendar = NSCalendar.current
        let date = calendar.date(byAdding: .day, value: interval, to: Date())!
        self.preferences.set(date, forKey: "rateUsDate")
        self.preferences.synchronize()
    }
    
    func rateApp(completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id1066174826?mt=8&action=write-review") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func shareThisApp() {
        if let myWebsite = NSURL(string: "http://apple.co/2mJwePJ") {
            let objectsToShare = [myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            let popUpView = self.view
            activityVC.popoverPresentationController?.sourceView = popUpView
            activityVC.popoverPresentationController?.sourceRect = (popUpView?.bounds)!
            activityVC.setValue("Tamil Christian Worship Songs on the App Store - iTunes - Apple", forKey: "Subject")
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
            self.present(activityVC, animated: true, completion: nil)
        }
    }

}
