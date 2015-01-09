//
//  CommonServiceTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/9/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import UIKit
import XCTest

class CommonServiceTest: XCTestCase {
    
    let commonService:CommonService = CommonService()
    
    func testGetPath(){
        println("--testGetPath--")
        var expectedPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent("songs.sqlite")
        var path = commonService.getDocumentDirectoryPath("songs.sqlite")
        XCTAssertNotNil(path, "Path value not nil")
        XCTAssertEqual(path, expectedPath, "Values are equal")
    }

    func testGetVersionNumber(){
        println("--testGetVersionNumber--")
        var versionNumber = commonService.getVersionNumber()
        XCTAssertNotNil(versionNumber,"versionNumber value not nil")
    }
}
