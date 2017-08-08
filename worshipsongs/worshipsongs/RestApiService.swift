//
//  RestApiService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 01/08/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import Foundation
class RestApiService: NSObject, NSURLConnectionDataDelegate
{
    var responseData:Data!
    let preferences = UserDefaults.standard
    var sha: String = ""
    
    func requestToGetDataAsDictionary(_ request : NSMutableURLRequest) -> NSDictionary
    {
        var jsonDictionaryData:NSDictionary = NSDictionary()
        sendRequest(request)
        CFRunLoopRun()
        if responseData != nil
        {
            let responseString = NSString(data: responseData, encoding:String.Encoding.utf8.rawValue);
            if responseString!.contains("Sorry! Something went wrong in the background.") {
                jsonDictionaryData = ["message" : "sessionExpired"] as NSDictionary
                return jsonDictionaryData
            }
            jsonDictionaryData = getJSONObjectWithData() as! NSDictionary
        }
        return jsonDictionaryData
    }
    
    func sendRequest(_ request : NSMutableURLRequest)
    {
        let connection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true) as NSURLConnection!
        connection?.start()
    }
    
    func getJSONObjectWithData() -> AnyObject?
    {
        do {
            return try JSONSerialization.jsonObject(with: responseData!, options: .mutableContainers) as AnyObject
        } catch let error as NSError {
            print("Error: \(error)")
            print("responseData: \(String(describing: NSString(data: responseData, encoding:String.Encoding.utf8.rawValue)))")
            return ["message" : "connectionFailed"] as NSDictionary
        }
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data)
    {
        self.responseData = data
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection)
    {
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error)
    {
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    func connection(_ connection:NSURLConnection, willSendRequestFor challenge:URLAuthenticationChallenge)
    {
        if challenge.previousFailureCount > 1
        {
            
        } else
        {
            challenge.sender!.use(URLCredential(trust: challenge.protectionSpace.serverTrust!), for: challenge)
        }
    }
    
    func checkUpdate(_ url: URL) -> Bool
    {
        var responseData:NSDictionary = NSDictionary()
        responseData = requestToGetDataAsDictionary(getRequest(url))
        var hasUpdate:Bool = false;
        var dictionary: NSDictionary
        if let data = responseData["object"] as? NSDictionary{
            dictionary = data
            if let message = dictionary["sha"] as? String
            {
                print("SHA: " + message)
                if !message.equalsIgnoreCase(preferences.string(forKey: "sha")!)
                {
                    sha = message
                    hasUpdate = true
                }
            }
        }
        return hasUpdate;
    }
    
    func getRequest(_ url: URL) -> NSMutableURLRequest
    {
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "GET"
        return request
    }
    
}
