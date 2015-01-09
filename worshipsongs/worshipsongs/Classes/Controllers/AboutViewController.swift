//
//  AboutViewController.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import Foundation

import UIKit

class AboutViewController: UIViewController,UIWebViewDelegate {
    var webView: UIWebView = UIWebView()
    
    let url = "http://apple.com"
    let urlpath = NSBundle.mainBundle().pathForResource("about", ofType: "html");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
            self.view.bounds.size.width, self.view.bounds.size.height);
        
        webView = UIWebView(frame: myFrame);

        
        var path = NSBundle.mainBundle().bundlePath
        
        var baseUrl  = NSURL.fileURLWithPath("\(path)")

        let bundle = NSBundle.mainBundle()
        let pathhtml = bundle.pathForResource("about", ofType: "html")
        let content = String(contentsOfFile:pathhtml!, encoding: NSUTF8StringEncoding, error: nil)
       webView.backgroundColor = UIColor.whiteColor()
        webView.loadHTMLString(content, baseURL: nil)
        webView.delegate = self
        webView.opaque = false
        webView.scrollView.scrollEnabled = true
        webView.scrollView.bounces = true
        webView.sizeToFit()
        self.view.addSubview(webView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
