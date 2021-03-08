//
//  CustomProvider.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 14/02/2019.
//  Copyright © 2019 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class CustomProvider : UIActivityItemProvider {
    var messagerMessage : String!
    var emailMessage : String!
    var otherMessage : String!
    
    init(placeholderItem: AnyObject, messagerMessage : String, emailMessage : String, otherMessage : String) {
        super.init(placeholderItem: placeholderItem)
        self.messagerMessage = messagerMessage
        self.emailMessage = emailMessage
        self.otherMessage = otherMessage
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        if activityType == UIActivityType.message {
            return messagerMessage as AnyObject?
        } else if activityType == UIActivityType.mail {
            return emailMessage as AnyObject?
        } else if activityType == UIActivityType.postToTwitter {
            return NSLocalizedString(messagerMessage, comment: "comment")
        } else if activityType?.rawValue == "net.whatsapp.WhatsApp.ShareExtension" {
            let whatsAppMessage = NSMutableAttributedString(string: messagerMessage)
            whatsAppMessage.append(NSAttributedString(string: "http://apple.co/2mJwePJ"))
            return whatsAppMessage.string as AnyObject?
        } else {
            return otherMessage
        }
    }
}
