//
//  UtilTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import UIKit
import XCTest



class UtilTest: XCTestCase {
    let util:Util = Util()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetPath(){
        println("--testGetPath--")
        var expectedPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent("songs.sqlite")
        var path = util.getPath("songs.sqlite")
        XCTAssertNotNil(path, "Path value not nil")
        XCTAssertEqual(path, expectedPath, "Values are equal")
    }
    
    func testParseJson(){
        println("--testParseJson--")
        var latestChangeSet = util.parseJson()
        XCTAssertNotNil(latestChangeSet, "latestChangeSet value not nil")
    }
    
    func testGetVersionNumber(){
        println("--testGetVersionNumber--")
         var versionNumber = util.getVersionNumber()
        XCTAssertNotNil(versionNumber,"versionNumber value not nil")
    }
}
