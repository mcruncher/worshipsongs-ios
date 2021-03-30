//
// author: Madasamy, Vignesh Palanisamy
// version: 1.7.0
//

import UIKit
import Foundation
import MessageUI

class SettingsController: UITableViewController {
    
    @IBOutlet weak var importDatabaseLabel: UILabel!
    @IBOutlet weak var importDatabaseCell: UITableViewCell!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var presentationFontSlider: UISlider!
    @IBOutlet weak var tamilFontColorTextField: UITextField!
    @IBOutlet weak var presentationTamilFontColorTextField: UITextField!
    @IBOutlet weak var englishFontColorTextField: UITextField!
    @IBOutlet weak var presentationEnglishFontColorTextField: UITextField!
    @IBOutlet weak var presentationBackgroundColorTextField: UITextField!
    @IBOutlet weak var restoreDatabaseLabel: UILabel!
    @IBOutlet weak var restoreDatabaseCell: UITableViewCell!
    
    @IBOutlet weak var presentationFontSize: UILabel!
    @IBOutlet weak var fontSIze: UILabel!
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
    @IBOutlet weak var primaryTamilColor: UITextField!
    @IBOutlet weak var primaryEnglishColor: UITextField!
    @IBOutlet weak var presentationTamilColor: UITextField!
    @IBOutlet weak var presentationEnglishColor: UITextField!
    @IBOutlet weak var presentationBackgroundColor: UITextField!
    @IBOutlet weak var displayTamilLabel: UILabel!
    @IBOutlet weak var displayRomanisedLabel: UILabel!
    @IBOutlet weak var displayTamilSwitch: UISwitch!
    @IBOutlet weak var displayRomanisedSwitch: UISwitch!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageValue: UILabel!
    @IBOutlet weak var updateSongsCell: UITableViewCell!
    @IBOutlet weak var updateSongsLabel: UILabel!
    @IBOutlet weak var searchByContent: UILabel!
    @IBOutlet weak var searchByContentSwitch: UISwitch!
    
    
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
        self.setLanguage()
        self.setPrimaryScreenFontSize()
        self.setPresentationScreenFontSize()
        self.setPrimaryScreenTamilFontColor()
        self.setPrimaryScreenEnglishFontColor()
        self.setPresentationScreenTamilFontColor()
        self.setPresentationScreenEnglishFontColor()
        self.setPresentationScreenBackgroundColor()
        self.setTamilSwitchValue()
        self.setRomanisedSwitchValue()
        self.setSearchBySwitchValue()
        let backButton = UIBarButtonItem(title: "back".localized, style: .plain, target: self, action: #selector(SettingsController.goBackToSongsList))
        navigationItem.leftBarButtonItem = backButton
        addTapGestureRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
    }
    
    func setUp() {
        languageLabel.text = "displayLanguage".localized
        rateUsLabel.text = "rateUs".localized
        feedBackLabel.text = "feedback".localized
        shareAppLabel.text = "shareApp".localized
        versionLabel.text = "version".localized
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionValueLabel.text = version
        }
        updateSongsLabel.text = "update.songs".localized
        importDatabaseLabel.text = "import.database".localized
        restoreDatabaseLabel.text = "restore.database".localized
        primaryTextSizeLabel.text = "text.size".localized
        primaryTamilColorLabel.text = "tamil.font.color".localized
        primaryEnglishColorLabel.text = "english.font.color".localized
        presentationTextSizeLabel.text = "text.size".localized
        presentationTamilColorLabel.text = "tamil.font.color".localized
        presentationEnglishColorLabel.text = "english.font.color".localized
        presentationBackgroundColorLabel.text = "background.color".localized
        displayTamilLabel.text = "display.tamil".localized
        displayRomanisedLabel.text = "display.romanised".localized
        searchByContent.text = "searchByContent".localized
        self.restoreDatabaseCell.isHidden = self.preferences.bool(forKey: "defaultDatabase")
        fontSizeSlider.minimumValue = 5
        fontSizeSlider.maximumValue = 40
        presentationFontSlider.minimumValue = 25
        presentationFontSlider.maximumValue = 999
    }
    
    fileprivate func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc internal func dismissKeyboard() {
        self.tamilFontColorTextField.resignFirstResponder()
        self.englishFontColorTextField.resignFirstResponder()
        self.presentationTamilFontColorTextField.resignFirstResponder()
        self.presentationEnglishFontColorTextField.resignFirstResponder()
        self.presentationBackgroundColorTextField.resignFirstResponder()
    }
    
    func setLanguage() {
        languageValue.text = self.preferences.string(forKey: "language")?.localized
    }
    
    func setPrimaryScreenFontSize() {
        let size = self.preferences.integer(forKey: "fontSize")
        fontSizeSlider.value = Float(size)
        fontSIze.text = String(size)
    }
    
    func setPresentationScreenFontSize() {
        let presentationSize = self.preferences.integer(forKey: "presentationFontSize")
        presentationFontSlider.value = Float(presentationSize)
        presentationFontSize.text = String(presentationSize)
    }
    
    func setPrimaryScreenTamilFontColor() {
        tamilFont = self.preferences.string(forKey: "tamilFontColor")!
        tamilFontColorTextField.text = tamilFont.localized
        primaryTamilColor.backgroundColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: tamilFont)!)
        tamilFontColorPickerView.tag = 1
        tamilFontColorPickerView.delegate = self
        tamilFontColorTextField.inputView = tamilFontColorPickerView
        tamilFontColorTextField.inputAccessoryView = getToolBar(currentField: tamilFontColorTextField)
        tamilFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: tamilFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPrimaryScreenEnglishFontColor() {
        englishFont = self.preferences.string(forKey: "englishFontColor")!
        englishFontColorTextField.text = englishFont.localized
        primaryEnglishColor.backgroundColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: englishFont)!)
        englishFontColorPickerView.tag = 2
        englishFontColorPickerView.delegate = self
        englishFontColorTextField.inputView = englishFontColorPickerView
        englishFontColorTextField.inputAccessoryView = getToolBar(currentField: englishFontColorTextField)
        englishFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: englishFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPresentationScreenTamilFontColor() {
        presentationTamilFont = self.preferences.string(forKey: "presentationTamilFontColor")!
        presentationTamilFontColorTextField.text = presentationTamilFont.localized
        presentationTamilColor.backgroundColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: presentationTamilFont)!)
        presentationTamilFontColorPickerView.tag = 3
        presentationTamilFontColorPickerView.delegate = self
        presentationTamilFontColorTextField.inputView = presentationTamilFontColorPickerView
        presentationTamilFontColorTextField.inputAccessoryView = getToolBar(currentField: presentationTamilFontColorTextField)
        presentationTamilFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: presentationTamilFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPresentationScreenEnglishFontColor() {
        presentationEnglishFont = self.preferences.string(forKey: "presentationEnglishFontColor")!
        presentationEnglishFontColorTextField.text = presentationEnglishFont.localized
        presentationEnglishColor.backgroundColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: presentationEnglishFont)!)
        presentationEnglishFontColorPickerView.tag = 4
        presentationEnglishFontColorPickerView.delegate = self
        presentationEnglishFontColorTextField.inputView = presentationEnglishFontColorPickerView
        presentationEnglishFontColorTextField.inputAccessoryView = getToolBar(currentField: presentationEnglishFontColorTextField)
        presentationEnglishFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: presentationEnglishFont)!)!, inComponent: 0, animated: true)
    }
    
    func setPresentationScreenBackgroundColor() {
        presentationBackground = self.preferences.string(forKey: "presentationBackgroundColor")!
        presentationBackgroundColorTextField.text = presentationBackground.localized
        presentationBackgroundColor.backgroundColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: presentationBackground)!)
        presentationBackgroundColorPickerView.tag = 5
        presentationBackgroundColorPickerView.delegate = self
        presentationBackgroundColorTextField.inputView = presentationBackgroundColorPickerView
        presentationBackgroundColorTextField.inputAccessoryView = getToolBar(currentField: presentationBackgroundColorTextField)
        presentationBackgroundColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: presentationBackground)!)!, inComponent: 0, animated: true)
    }
    
    func setTamilSwitchValue() {
        let displayTamil = self.preferences.bool(forKey: "displayTamil")
        displayTamilSwitch.isOn = displayTamil
    }
    
    func setRomanisedSwitchValue() {
        let displayRomanised = self.preferences.bool(forKey: "displayRomanised")
        displayRomanisedSwitch.isOn = displayRomanised
    }
    
    func setSearchBySwitchValue() {
        searchByContentSwitch.isOn = "searchByContent".equalsIgnoreCase(self.preferences.string(forKey: "searchBy")!)
    }
    
    func getToolBar(currentField: UITextField) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "done".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsController.doneEditing))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    @objc func doneEditing() {
        dismissKeyboard()
    }
    
    
    @objc func goBackToSongsList() {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 8
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "searchBy".localized
        case 2:
            return "language".localized
        case 3:
            return "lyricsPreference".localized
        case 4:
            return "primary.screen".localized
        case 5:
            return "presentation.screen".localized
        case 6:
            return "advanced".localized
        case 7:
            return "general".localized
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.black
        }
        view.backgroundColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        importDatabaseLabel.isEnabled = !self.preferences.bool(forKey: "database.lock")
        if section == 6 && self.preferences.bool(forKey: "defaultDatabase") {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                updateSongs()
                break
            default:
                break
            }
        }
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                selectLanguage()
                break
            default:
                break
            }
        }
        if indexPath.section == 4 {
            switch indexPath.row {
            case 1:
                tamilFontColorTextField.becomeFirstResponder()
                break
            case 2:
                englishFontColorTextField.becomeFirstResponder()
                break
            default:
                break
            }
        }
        if indexPath.section == 5 {
            switch indexPath.row {
            case 1:
                presentationTamilFontColorTextField.becomeFirstResponder()
                break
            case 2:
                presentationEnglishFontColorTextField.becomeFirstResponder()
                break
            case 3:
                presentationBackgroundColorTextField.becomeFirstResponder()
                break
            default:
                break
            }
        }
        if indexPath.section == 6 {
            switch indexPath.row {
            case 0:
                importDatabase()
                break
            case 1:
                restoreDatabase()
                break
            default:
                break
            }
        }
        if indexPath.section == 7 {
            switch indexPath.row {
            case 0:
                rateUs()
                break
            case 1:
                shareThisApp()
                break
            case 2:
                sendEmail()
                break
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerHeight: CGFloat
        
        switch section {
        case 0:
            // hide the header
            headerHeight = CGFloat.leastNonzeroMagnitude
        default:
            headerHeight = super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        return headerHeight
    }
    
    func selectLanguage() {
        let optionMenu = UIAlertController(title: nil, message: "language".localized, preferredStyle: .actionSheet)
        optionMenu.addAction(changeLanguageAction("tamil"))
        optionMenu.addAction(changeLanguageAction("english"))
        optionMenu.addAction(getOptionCancelAction())
        optionMenu.popoverPresentationController?.sourceView = importDatabaseCell.contentView
        optionMenu.popoverPresentationController?.sourceRect = importDatabaseCell.contentView.bounds
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func changeLanguageAction(_ language: String) -> UIAlertAction  {
        return UIAlertAction(title: language.localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.preferences.setValue(language, forKey: "language")
            self.preferences.synchronize()
            self.languageValue.text = self.preferences.string(forKey: "language")?.localized
        })
    }
    
    @objc func revertDatabase(_ nsNotification: NSNotification) {
        databaseService.revertImport()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTabbar"), object: nil,  userInfo: nil)
    }
    
    @IBAction func onChangeSize(_ sender: Any) {
        self.preferences.setValue(fontSizeSlider.value, forKey: "fontSize")
        self.preferences.synchronize()
        fontSIze.text = String(self.preferences.integer(forKey: "fontSize"))
    }
    
    @IBAction func onChangeTamilSwitch(_ sender: Any) {
        self.preferences.setValue(displayTamilSwitch.isOn, forKey: "displayTamil")
        self.preferences.synchronize()
    }
    
    @IBAction func onChangeEnglishSwitch(_ sender: Any) {
        self.preferences.setValue(displayRomanisedSwitch.isOn, forKey: "displayRomanised")
        self.preferences.synchronize()
    }
    
    @IBAction func searchSongsByContent(_ sender: Any) {
        if searchByContentSwitch.isOn {
            self.preferences.setValue("searchByContent", forKey: "searchBy")
        } else {
            self.preferences.setValue("", forKey: "searchBy")
        }
        self.preferences.synchronize()
    }
    
    func updateSongs() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "updating") as? UpdateSongsViewController
        viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.present(viewController!, animated: false, completion: nil)
    }
    
    fileprivate func getConfirmationAlertController() -> UIAlertController
    {
        let confirmationAlertController = self.getMoveController(message: "Updates Available")
        confirmationAlertController.addAction(self.getMoveAction())
        confirmationAlertController.addAction(self.getCancelAction(title: "no"))
        return confirmationAlertController
    }
    
    fileprivate func getMoveController(message: String) -> UIAlertController
    {
        return UIAlertController(title: "Update", message: message.localized, preferredStyle: UIAlertControllerStyle.alert)
    }
    
    fileprivate func getMoveAction() -> UIAlertAction
    {
        return UIAlertAction(title: "Yes", style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
        })
        
    }
    
    fileprivate func getCancelAction(title: String) -> UIAlertAction
    {
        return UIAlertAction(title: title.localized, style: UIAlertActionStyle.default,handler: {(alert: UIAlertAction!) -> Void in
        })
    }
    
    func restoreDatabase() {
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
    
    func updatesongs() {
        let optionMenu = UIAlertController(title: nil, message: "import.database".localized, preferredStyle: .actionSheet)
        optionMenu.addAction(getDatabaseFromiCloudAction())
        optionMenu.addAction(getDatabaseFromRemoteUrlAction())
        optionMenu.addAction(getOptionCancelAction())
        optionMenu.popoverPresentationController?.sourceView = importDatabaseCell.contentView
        optionMenu.popoverPresentationController?.sourceRect = importDatabaseCell.contentView.bounds
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func importDatabase() {
        let optionMenu = UIAlertController(title: nil, message: "import.database".localized, preferredStyle: .actionSheet)
        optionMenu.addAction(getDatabaseFromiCloudAction())
        optionMenu.addAction(getDatabaseFromRemoteUrlAction())
        optionMenu.addAction(getOptionCancelAction())
        optionMenu.popoverPresentationController?.sourceView = importDatabaseCell.contentView
        optionMenu.popoverPresentationController?.sourceRect = importDatabaseCell.contentView.bounds
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
    
    fileprivate func getOptionCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
    }
    
    @IBAction func onChangePresentationSize(_ sender: Any) {
        self.preferences.setValue(presentationFontSlider.value, forKey: "presentationFontSize")
        self.preferences.synchronize()
        presentationFontSize.text = String(self.preferences.integer(forKey: "presentationFontSize"))
    }
    
    func rateUs() {
        rateApp(appId: "1066174826") { success in
            print("RateApp \(success)")
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
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
            let objectsToShare = [myWebsite.absoluteString]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            let popUpView = self.tableView.cellForRow(at: tableView.indexPathForSelectedRow!)?.contentView
            activityVC.popoverPresentationController?.sourceView = popUpView
            activityVC.popoverPresentationController?.sourceRect = (popUpView?.bounds)!
            activityVC.setValue("Tamil Christian Worship Songs on the App Store - iTunes - Apple", forKey: "Subject")
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.saveToCameraRoll, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType(rawValue: "Reminders")]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if DeviceUtils.isIpad() {
            splitViewController?.preferredPrimaryColumnWidthFraction = 1.0
            splitViewController?.maximumPrimaryColumnWidth = (splitViewController?.view.bounds.size.width)!
            let leftNavController = splitViewController?.viewControllers.first as! UINavigationController
            leftNavController.view.frame = CGRect(x: leftNavController.view.frame.origin.x, y: leftNavController.view.frame.origin.y, width: (splitViewController?.view.bounds.size.width)!, height: leftNavController.view.frame.height)
        }
    }
    
}

extension SettingsController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            tamilFontColorTextField.text = tamilFont.localized
            return ColorList.count
        } else {
            englishFontColorTextField.text = englishFont.localized
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
            tamilFontColorTextField.text = tamilFont.localized
            primaryTamilColor.backgroundColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(tamilFont, forKey: "tamilFontColor")
            self.preferences.synchronize()
        } else if pickerView.tag == 2 {
            englishFont = ColorList[row].rawValue
            englishFontColorTextField.text = englishFont.localized
            primaryEnglishColor.backgroundColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(englishFont, forKey: "englishFontColor")
            self.preferences.synchronize()
        } else if pickerView.tag == 3 {
            presentationTamilFont = ColorList[row].rawValue
            presentationTamilFontColorTextField.text = presentationTamilFont.localized
            presentationTamilColor.backgroundColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(presentationTamilFont, forKey: "presentationTamilFontColor")
            self.preferences.synchronize()
        } else if pickerView.tag == 4 {
            presentationEnglishFont = ColorList[row].rawValue
            presentationEnglishFontColorTextField.text = presentationEnglishFont.localized
            presentationEnglishColor.backgroundColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(presentationEnglishFont, forKey: "presentationEnglishFontColor")
            self.preferences.synchronize()
        } else {
            presentationBackground = ColorList[row].rawValue
            presentationBackgroundColorTextField.text = presentationBackground.localized
            presentationBackgroundColor.backgroundColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(presentationBackground, forKey: "presentationBackgroundColor")
            self.preferences.synchronize()
        }
    }
}

extension SettingsController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if url.pathExtension.equalsIgnoreCase("sqlite") {
                importDatabaseLabel.isEnabled = false
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
        mailComposerVC.setToRecipients(["appfeedback@mcruncher.com"])
        mailComposerVC.setSubject("Worship Songs iOS Feedback")
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
