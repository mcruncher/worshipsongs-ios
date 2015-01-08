//
//  ConnectionServiceTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import XCTest

class ConnectionServiceTest: XCTestCase {

    let connectionService:ConnectionService = ConnectionService()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIsConnectedToNetwork(){
        var result:Bool = true
        XCTAssertEqual(connectionService.isConnectedToNetwork(), result, "")
    }

}
