//
//  PresentationData.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 02/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import Foundation
import UIKit

class PresentationData {
    
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    fileprivate let preferences = UserDefaults.standard
    var secondWindow: UIWindow?
    let secondScreenView = PresentationView()
    
    func registerForScreenNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PresentationData.setupScreen), name: NSNotification.Name.UIScreenDidConnect, object: nil)
    }
    
    @objc func setupScreen() {
        if UIScreen.screens.count > 1 {
            let secondScreen = UIScreen.screens[1]
            secondWindow = UIWindow(frame: secondScreen.bounds)
            secondWindow?.screen = secondScreen
            secondScreenView.frame = (secondWindow!.frame)
            secondWindow?.addSubview(secondScreenView)
            secondWindow?.isHidden = false
            secondScreenView.backgroundColor = UIColor.white
            if isPresentationStringNotEmpty() {
                secondScreenView.songLabel.numberOfLines = 0
                secondScreenView.songLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                let presentationText = self.preferences.string(forKey: "presentationLyrics")
                let customTextSettingService: CustomTextSettingService = CustomTextSettingService()
                secondScreenView.songLabel.attributedText = customTextSettingService.getAttributedString(NSString(string:presentationText!))
                secondScreenView.authorLabel.text = "artist".localized + ": " + self.preferences.string(forKey: "presentationAuthor")!
                secondScreenView.slideNumberLabel.text = self.preferences.string(forKey: "presentationSlide")
                secondScreenView.songNameLabel.text = self.preferences.string(forKey: "presentationSongName")
            } else {
                let attachment:NSTextAttachment = NSTextAttachment()
                attachment.image = UIImage(named: "Default-Landscape")
                let attachmentString = NSAttributedString(attachment: attachment)
                secondScreenView.songLabel.attributedText = attachmentString
            }
        }
    }
    
    fileprivate func isPresentationStringNotEmpty() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("presentationLyrics") && self.preferences.string(forKey: "presentationLyrics") != ""
    }
    
    func updateScreen() {
        secondScreenView.songLabel.numberOfLines = 0
        secondScreenView.songLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        let presentationText = self.preferences.string(forKey: "presentationLyrics")
        let customTextSettingService: CustomTextSettingService = CustomTextSettingService()
        secondScreenView.songLabel.attributedText = customTextSettingService.getAttributedString(NSString(string:presentationText!))
        secondScreenView.authorLabel.text = "artist".localized + ": " + self.preferences.string(forKey: "presentationAuthor")!
        secondScreenView.slideNumberLabel.text = self.preferences.string(forKey: "presentationSlide")
        secondScreenView.songNameLabel.text = self.preferences.string(forKey: "presentationSongName")
    }

}
