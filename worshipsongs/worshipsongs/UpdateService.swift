//
//  UpdateService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 01/08/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import Foundation
class UpdateService: NSObject, NSURLConnectionDataDelegate {
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let preferences = UserDefaults.standard
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                    do {
                        if statusCode == 200 {
                            preferences.setValue("updated.sucessfully", forKey: "update.status")
                            preferences.synchronize()
                            if FileManager.default.fileExists(atPath: localUrl.path) {
                                try! FileManager.default.removeItem(atPath: localUrl.path)
                            }
                            try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                            preferences.setValue("updated.song", forKey: "update.status")
                            preferences.synchronize()
                            preferences.set(false, forKey: "defaultDatabase")
                            preferences.synchronize()
                        } else {
                            preferences.setValue("error.updating", forKey: "update.status")
                            preferences.synchronize()
                        }
                        completion()
                        preferences.set(false, forKey: "update.lock")
                        preferences.synchronize()
                    } catch (let writeError) {
                        preferences.setValue("error.copying", forKey: "update.status")
                        preferences.set(false, forKey: "update.lock")
                        preferences.synchronize()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "revertUpdate"), object: nil,  userInfo: nil)
                        print("error writing file \(localUrl) : \(writeError)")
                    }
                } else {
                    preferences.setValue("error.updating", forKey: "update.status")
                    preferences.set(false, forKey: "update.lock")
                    preferences.synchronize()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "revertUpdate"), object: nil,  userInfo: nil)
                }
                
            } else {
                preferences.setValue("error.updating", forKey: "update.status")
                preferences.set(false, forKey: "update.lock")
                preferences.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "revertUpdate"), object: nil,  userInfo: nil)
                print("Failure: %@ \(error?.localizedDescription)");
            }
        }
        task.resume()
    }
}
