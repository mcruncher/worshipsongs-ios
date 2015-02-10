//
//  DownloadService.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 2/9/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation

class DownloadService: NSObject {
    let utilClass:Util = Util()
    let connectionService:ConnectionService = ConnectionService()
    
    func checkConnectionAndDownloadFile()
    {
        sleep(5)
        if(connectionService.isConnectedToNetwork()){
            let statusType = connectionService.isConnectedToNetworkOfType()
            switch statusType{
            case .WWAN:
                utilClass.downloadFile()
            case .WiFi:
                utilClass.downloadFile()
            case .NotConnected:
                println("Connection Type: Not connected to the Internet")
            }
        }
        else
        {
            println("Internet Connection: Unavailable")
            let latestChangeSetInUserDefults  = NSUserDefaults.standardUserDefaults().objectForKey("latestChangeSet") as NSString!
            if (latestChangeSetInUserDefults == nil)
            {
                utilClass.copyFile("songs.sqlite")
            }
        }
    }
    
}