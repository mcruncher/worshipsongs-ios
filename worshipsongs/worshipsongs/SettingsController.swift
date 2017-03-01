//
//  SettingsController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 02/12/2016.
//  Copyright © 2016 Vignesh Palanisamy. All rights reserved.
//

import UIKit
import Foundation
import FileBrowser
import MessageUI

class SettingsController: UITableViewController {

    @IBOutlet weak var importDatabaseButton: UIButton!
    @IBOutlet weak var importDatabaseCell: UITableViewCell!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var presentationFontSlider: UISlider!
    @IBOutlet weak var tamilFontColor: UITextField!
    @IBOutlet weak var presentationTamilFontColor: UITextField!
    @IBOutlet weak var englishFontColor: UITextField!
    @IBOutlet weak var presentationEnglishFontColor: UITextField!
    @IBOutlet weak var presentationBackgroundColor: UITextField!
    @IBOutlet weak var restoreDatabaseButton: UIButton!
    @IBOutlet weak var restoreDatabaseCell: UITableViewCell!
    
    @IBOutlet weak var primaryTextSizeLabel: UILabel!
    @IBOutlet weak var primaryTamilColorLabel: UILabel!
    @IBOutlet weak var primaryEnglishColorLabel: UILabel!
    @IBOutlet weak var presentationTextSizeLabel: UILabel!
    
    @IBOutlet weak var presentationTamilColorLabel: UILabel!
    
    @IBOutlet weak var presentationEnglishColorLabel: UILabel!
    
    @IBOutlet weak var presentationBackgroundColorLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionValueLabel: UILabel!
    @IBOutlet weak var rateUsLabel: UILabel!
    @IBOutlet weak var feedBackLabel: UILabel!
    @IBOutlet weak var shareAppLabel: UILabel!
    
    fileprivate let preferences = UserDefaults.standard
    fileprivate let ColorList = ColorUtils.Color.allValues
    var englishFont: String = ""
    var tamilFont: String = ""
    var presentationEnglishFont: String = ""
    var presentationTamilFont: String = ""
    var presentationBackground: String = ""
    fileprivate let tamilFontColorPickerView = UIPickerView()
    fileprivate let englishFontColorPickerView = UIPickerView()
    fileprivate let presentationBackgroundColorPickerView = UIPickerView()
    fileprivate let presentationTamilFontColorPickerView = UIPickerView()
    fileprivate let presentationEnglishFontColorPickerView = UIPickerView()
    fileprivate let databaseService = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsController.revertDatabase(_:)), name: NSNotification.Name(rawValue: "revertDatabase"), object: nil)
        self.setUp()
        self.setPrimaryScreenFontSize()
        self.setPresentationScreenFontSize()
        self.setPrimaryScreenTamilFontColor()
        self.setPrimaryScreenEnglishFontColor()
        self.setPresentationScreenTamilFontColor()
        self.setPresentationScreenEnglishFontColor()
        self.setPresentationScreenBackgroundColor()
        let backButton = UIBarButtonItem(title: "back".localized, style: .plain, target: self, action: #selector(SettingsController.goBackToSongsList))
        navigationItem.leftBarButtonItem = backButton
    }
    
    func setUp() {
        rateUsLabel.text = "rateUs".localized
        feedBackLabel.text = "feedback".localized
        shareAppLabel.text = "shareApp".localized
        versionLabel.text = "version".localized
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionValueLabel.text = version
        }
        importDatabaseButton.setTitle("import.database".localized, for: .normal)
        restoreDatabaseButton.setTitle("restore.database".localized, for: .normal)
        primaryTextSizeLabel.text = "text.size".localized
        primaryTamilColorLabel.text = "tamil.font.color".localized
        primaryEnglishColorLabel.text = "english.font.color".localized
        
        presentationTextSizeLabel.text = "text.size".localized
        presentationTamilColorLabel.text = "tamil.font.color".localized
        presentationEnglishColorLabel.text = "english.font.color".localized
        presentationBackgroundColorLabel.text = "background.color".localized
        self.restoreDatabaseCell.isHidden = self.preferences.bool(forKey: "defaultDatabase")
    }
    
    func setPrimaryScreenFontSize() {
        let size = self.preferences.integer(forKey: "fontSize")
        fontSizeSlider.value = Float(size)
    }
    
    func setPresentationScreenFontSize() {
        let presentationSize = self.preferences.integer(forKey: "presentationFontSize")
        presentationFontSlider.value = Float(presentationSize)
    }
    
    func setPrimaryScreenTamilFontColor() {
        tamilFont = self.preferences.string(forKey: "tamilFontColor")!
        tamilFontColor.text = tamilFont.localized
        tamilFontColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: tamilFont)!)
        tamilFontColorPickerView.tag = 1
        tamilFontColorPickerView.delegate = self
        tamilFontColor.inputView = tamilFontColorPickerView
        tamilFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: tamilFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPrimaryScreenEnglishFontColor() {
        englishFont = self.preferences.string(forKey: "englishFontColor")!
        englishFontColor.text = englishFont.localized
        englishFontColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: englishFont)!)
        englishFontColorPickerView.tag = 2
        englishFontColorPickerView.delegate = self
        englishFontColor.inputView = englishFontColorPickerView
        englishFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: englishFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPresentationScreenTamilFontColor() {
        presentationTamilFont = self.preferences.string(forKey: "presentationTamilFontColor")!
        presentationTamilFontColor.text = presentationTamilFont.localized
        presentationTamilFontColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: presentationTamilFont)!)
        presentationTamilFontColorPickerView.tag = 3
        presentationTamilFontColorPickerView.delegate = self
        presentationTamilFontColor.inputView = presentationTamilFontColorPickerView
        presentationTamilFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: presentationTamilFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPresentationScreenEnglishFontColor() {
        presentationEnglishFont = self.preferences.string(forKey: "presentationEnglishFontColor")!
        presentationEnglishFontColor.text = presentationEnglishFont.localized
        presentationEnglishFontColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: presentationEnglishFont)!)
        presentationEnglishFontColorPickerView.tag = 4
        presentationEnglishFontColorPickerView.delegate = self
        presentationEnglishFontColor.inputView = presentationEnglishFontColorPickerView
        presentationEnglishFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: presentationEnglishFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPresentationScreenBackgroundColor() {
        presentationBackground = self.preferences.string(forKey: "presentationBackgroundColor")!
        presentationBackgroundColor.text = presentationBackground.localized
        presentationBackgroundColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: presentationBackground)!)
        presentationBackgroundColorPickerView.tag = 5
        presentationBackgroundColorPickerView.delegate = self
        presentationBackgroundColor.inputView = presentationBackgroundColorPickerView
        presentationBackgroundColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: presentationBackground)!)!, inComponent: 0, animated: true)
    }
    
    
    func goBackToSongsList() {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "database".localized
        case 1:
            return "primary.screen".localized
        case 2:
            return "presentation.screen".localized
        case 3:
            return "general".localized
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        importDatabaseButton.isEnabled = !self.preferences.bool(forKey: "database.lock")
        if section == 0 && self.preferences.bool(forKey: "defaultDatabase") {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                rateUs()
                break
            case 1:
                sendEmail()
                break
            case 2:
                shareThisApp()
                break
            default:
                break
            }
        }
    }
    
    func revertDatabase(_ nsNotification: NSNotification) {
        databaseService.revertImport()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onAfterUpdateDatabase"), object: nil,  userInfo: nil)
    }
    
    @IBAction func onChangeSize(_ sender: Any) {
        self.preferences.setValue(fontSizeSlider.value, forKey: "fontSize")
        self.preferences.synchronize()
    }
    
    @IBAction func restoreDatabase(_ sender: Any) {
        let alert = getAlertController("restore.database".localized, message: "message.restore.database".localized)
        alert.addAction(getYesAction("yes".localized))
        alert.addAction(getNoAction())
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func getAlertController(_ title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    fileprivate func getYesAction(_ title: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: {(alert: UIAlertAction!) -> Void in
            self.databaseService.restoreDatabase()
            self.restoreDatabaseCell.isHidden = true
            self.tableView.reloadData()
        })
    }
    
    fileprivate func getNoAction() -> UIAlertAction {
        return UIAlertAction(title: "no".localized, style: .default, handler: nil)
    }
    
    @IBAction func importDatabase(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "import.database".localized, preferredStyle: .actionSheet)
        optionMenu.addAction(getDatabaseFromiCloudAction())
        optionMenu.addAction(getDatabaseFromRemoteUrlAction())
        optionMenu.addAction(getDatabaseCancelAction())
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func getDatabaseFromiCloudAction() -> UIAlertAction  {
        return UIAlertAction(title: "import.iCloud".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
            documentPickerController.delegate = self
            self.present(documentPickerController, animated: true, completion: nil)
        })
    }
    
    func getDatabaseFromRemoteUrlAction() -> UIAlertAction  {
        return UIAlertAction(title: "import.remoteURL".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "remoteUrl", sender: self)
        })
    }
    
    fileprivate func getDatabaseCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
    }
    
    @IBAction func onChangePresentationSize(_ sender: Any) {
        self.preferences.setValue(presentationFontSlider.value, forKey: "presentationFontSize")
        self.preferences.synchronize()
    }
    
    func rateUs() {
        rateApp(appId: "1066174826") { success in
            print("RateApp \(success)")
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" + appId) else {
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
            let objectsToShare = [myWebsite.absoluteString]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
            self.present(activityVC, animated: true, completion: nil)
        }
    }

}

extension SettingsController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            tamilFontColor.text = tamilFont.localized
            return ColorList.count
        } else {
            englishFontColor.text = englishFont.localized
            return ColorList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return ColorList[row].rawValue.localized
        } else {
            return ColorList[row].rawValue.localized
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            tamilFont = ColorList[row].rawValue
            tamilFontColor.text = tamilFont.localized
            tamilFontColor.textColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(tamilFont, forKey: "tamilFontColor")
            self.preferences.synchronize()
        } else if pickerView.tag == 2 {
            englishFont = ColorList[row].rawValue
            englishFontColor.text = englishFont.localized
            englishFontColor.textColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(englishFont, forKey: "englishFontColor")
            self.preferences.synchronize()
        } else if pickerView.tag == 3 {
            presentationTamilFont = ColorList[row].rawValue
            presentationTamilFontColor.text = presentationTamilFont.localized
            presentationTamilFontColor.textColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(presentationTamilFont, forKey: "presentationTamilFontColor")
            self.preferences.synchronize()
        } else if pickerView.tag == 4 {
            presentationEnglishFont = ColorList[row].rawValue
            presentationEnglishFontColor.text = presentationEnglishFont.localized
            presentationEnglishFontColor.textColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(presentationEnglishFont, forKey: "presentationEnglishFontColor")
            self.preferences.synchronize()
        } else {
            presentationBackground = ColorList[row].rawValue
            presentationBackgroundColor.text = presentationBackground.localized
            presentationBackgroundColor.textColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(presentationBackground, forKey: "presentationBackgroundColor")
            self.preferences.synchronize()
        }
    }
}

extension SettingsController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if url.pathExtension.equalsIgnoreCase("sqlite") {
                importDatabaseButton.isEnabled = false
                databaseService.importDriveDatabase(url: url)
                self.navigationController!.popToRootViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "invalid.file".localized, message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
}

extension SettingsController: MFMailComposeViewControllerDelegate {
    
    
    func sendEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["technical@mcruncher.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Write your feedback here:", isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Could Not Send Email".localized, message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
