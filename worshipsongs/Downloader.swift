//
//  Downloader.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 24/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import Foundation
class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let localPreferences = UserDefaults.standard
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                    do {
                        if statusCode == 200 {
                            localPreferences.set("imported.sucessfully", forKey: "import.status")
                            localPreferences.synchronize()
                            if FileManager.default.fileExists(atPath: localUrl.path) {
                                try! FileManager.default.removeItem(atPath: localUrl.path)
                            }
                            try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                            localPreferences.set(false, forKey: "defaultDatabase")
                            localPreferences.synchronize()
                        } else {
                            localPreferences.set("error.importing", forKey: "import.status")
                            localPreferences.synchronize()
                        }
                        completion()
                        localPreferences.set(false, forKey: "database.lock")
                        localPreferences.synchronize()
                    } catch (let writeError) {
                        localPreferences.set("error.copying", forKey: "import.status")
                        localPreferences.set(false, forKey: "database.lock")
                        localPreferences.synchronize()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "revertDatabase"), object: nil,  userInfo: nil)
                        print("error writing file \(localUrl) : \(writeError)")
                    }
                } else {
                    localPreferences.set("error.importing", forKey: "import.status")
                    localPreferences.set(false, forKey: "database.lock")
                    localPreferences.synchronize()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "revertDatabase"), object: nil,  userInfo: nil)
                }
                
            } else {
                localPreferences.set("error.importing", forKey: "import.status")
                localPreferences.set(false, forKey: "database.lock")
                localPreferences.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "revertDatabase"), object: nil,  userInfo: nil)
                print("Failure: %@ \(error?.localizedDescription)");
            }
        }
        task.resume()
    }
}
