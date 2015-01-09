//
//  CustomTextSettingServiceTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import UIKit
import XCTest

class CustomTextSettingServiceTest: XCTestCase {
    
    let customTextSettingService:CustomTextSettingService = CustomTextSettingService()
    var textRange: NSMutableArray = NSMutableArray()
    var string: NSString!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        string = "{y}எதினால் இது எதினால்" +
            "நீர் என்னோடு வருவதினால் (2x){/y}" +
            "Ethinaal ithu ethinaal" +
            "Neer yennodu varuvathinaal (2x)" +
        "{y}உந்தன் நாமம் போற்றிடவே{/y}"
        var range1:NSRange = NSMakeRange(0,54)
        var range2:NSRange = NSMakeRange(107,29)
        textRange.addObject(range1)
        textRange.addObject(range2)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetAttributedString(){
        println("--testGetAttributedString--")
        var attributedString = customTextSettingService.getAttributedString("Hello")
        XCTAssertNotNil(attributedString, "latestChangeSet value not nil")
    }
    
    func testGetCustomTagRanges(){
        println("--testGetCustomTagRanges--")
        var rangeArray = customTextSettingService.getCustomTagRanges(string)
        XCTAssertNotNil(rangeArray, "latestChangeSet value not nil")
        XCTAssertEqual(textRange, rangeArray, "Values are Equal")
    }
    
    func testFindRange(){
        println("--testFindRange--")
        var tagRange:NSMutableArray = customTextSettingService.findCustomTagTextRange(string, customTagRangeArray: textRange)
        var modifiedRange: NSMutableArray = NSMutableArray()
        var range1:NSRange = NSMakeRange(0,47)
        var range2:NSRange = NSMakeRange(100,22)
        modifiedRange.addObject(range1)
        modifiedRange.addObject(range2)
        XCTAssertNotNil(tagRange, "latestChangeSet value not nil")
        XCTAssertEqual(modifiedRange, tagRange, "Values are Equal")
    }
    
    func testRemovePattern(){
        println("--testRemovePattern--")
        var stringValue = "{y}எதினால் இது எதினால்{/y}"
        var expectedResult:NSString = "எதினால் இது எதினால்"
        var text = customTextSettingService.removePattern(stringValue)
        XCTAssertEqual(expectedResult, text, "Values are Equal")
    }
    
    func testTotalPatternLengthValue(){
        println("--testTotalPatternLengthValue--")
        var stringValue = "{y}எதினால் இது எதினால்{/y}"
        var expectedLength:Int = 7
        var length = customTextSettingService.totalPatternLengthValue(stringValue)
        XCTAssertEqual(expectedLength, length, "Values are Equal")
    }
    
    
}
