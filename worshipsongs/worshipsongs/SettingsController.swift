//
//  SettingsController.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 02/12/2016.
//  Copyright © 2016 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var presentationFontSlider: UISlider!
    @IBOutlet weak var tamilFontColor: UITextField!
    @IBOutlet weak var englishFontColor: UITextField!
    fileprivate let preferences = UserDefaults.standard
    fileprivate let ColorList = ColorUtils.Color.allValues
    var englishFont: String = ""
    var tamilFont: String = ""
    fileprivate let tamilFontColorPickerView = UIPickerView()
    fileprivate let englishFontColorPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size = self.preferences.integer(forKey: "fontSize")
        fontSizeSlider.value = Float(size)
        let presentationSize = self.preferences.integer(forKey: "presentationFontSize")
        presentationFontSlider.value = Float(presentationSize)
        tamilFont = self.preferences.string(forKey: "tamilFontColor")!
        tamilFontColor.text = tamilFont.localized
        tamilFontColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: tamilFont)!)
        tamilFontColorPickerView.tag = 1
        tamilFontColorPickerView.delegate = self
        tamilFontColor.inputView = tamilFontColorPickerView
        tamilFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: tamilFont)!)!, inComponent: 0, animated: true)
        englishFont = self.preferences.string(forKey: "englishFontColor")!
        englishFontColor.text = englishFont.localized
        englishFontColor.textColor = ColorUtils.getColor(color: ColorUtils.Color(rawValue: englishFont)!)
        englishFontColorPickerView.tag = 2
        englishFontColorPickerView.delegate = self
        englishFontColor.inputView = englishFontColorPickerView
        englishFontColorPickerView.selectRow(ColorList.index(of: ColorUtils.Color(rawValue: englishFont)!)!, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    @IBAction func onChangeSize(_ sender: Any) {
        self.preferences.setValue(fontSizeSlider.value, forKey: "fontSize")
        self.preferences.synchronize()
    }
    
    @IBAction func onChangePresentationSize(_ sender: Any) {
        self.preferences.setValue(presentationFontSlider.value, forKey: "presentationFontSize")
        self.preferences.synchronize()
    }
    
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
        } else {
            englishFont = ColorList[row].rawValue
            englishFontColor.text = englishFont.localized
            englishFontColor.textColor = ColorUtils.getColor(color: ColorList[row])
            self.preferences.setValue(englishFont, forKey: "englishFontColor")
            self.preferences.synchronize()
        }
    }

}
