//
//  RegexPatternMatcherServiceTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//


import XCTest

class RegexPatternMatcherServiceTest: XCTestCase {
    
    let regexMatcher:RegexPatternMatcherService = RegexPatternMatcherService()
    var textRange: NSMutableArray = NSMutableArray()
    var string: NSString!
    let startPattern = "\\{\\w\\}"
    let endPattern = "\\{/\\w\\}"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        string = "{y}எதினால் இது எதினால்" +
            "நீர் என்னோடு வருவதினால் (2x){/y}" +
            "Ethinaal ithu ethinaal" +
            "Neer yennodu varuvathinaal (2x)" +
        "{y}உந்தன் நாமம் போற்றிடவே{/y}"
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetRange (){
        println("--testGetRange--")
        var expectedStartTagRange: NSMutableArray = NSMutableArray()
        var expectedEndTagRange: NSMutableArray = NSMutableArray()
        expectedStartTagRange.addObject(NSMakeRange(0,3))
        expectedStartTagRange.addObject(NSMakeRange(107,3))
        expectedEndTagRange.addObject(NSMakeRange(50,4))
        expectedEndTagRange.addObject(NSMakeRange(132,4))
        var startTagRange = regexMatcher.getRange(string, pattern: startPattern)
        var endTagRange = regexMatcher.getRange(string, pattern: endPattern)
        XCTAssertEqual(expectedStartTagRange, startTagRange, "StartTagRange are equal")
        XCTAssertEqual(expectedEndTagRange, endTagRange, "EndTagRange are equal")
    }
    
    func testRemovePatternText(){
        println("--testRemovePatternText--")
        var result1:BooleanType!
        var inputText = "{y}எதினால் இது எதினால்{/y}"
        var expectedStartPatternText = "எதினால் இது எதினால்{/y}"
        var expectedEndPatternText = "{y}எதினால் இது எதினால்"
        var expectedStartPatternRemovedText = regexMatcher.removePatternText(inputText, pattern: startPattern)
        var expectedEndPatternRemovedText = regexMatcher.removePatternText(inputText, pattern: endPattern)
        XCTAssertTrue(expectedStartPatternText == expectedStartPatternRemovedText, "")
        XCTAssertTrue(expectedEndPatternText == expectedEndPatternRemovedText, "")
    }
    
    func testGetPatternTextLength (){
        println("--testGetPatternTextLength--")
        var inputText = "{y}எதினால் இது எதினால்{/y}"
        var expectedStartPatternLength = 3
        var expectedEndPatternLength = 4
        var startPatternLength = regexMatcher.getPatternTextLength(inputText, pattern: startPattern)
        var endPatternLength = regexMatcher.getPatternTextLength(inputText, pattern: endPattern)
        XCTAssertTrue(expectedStartPatternLength == startPatternLength, "")
        XCTAssertTrue(expectedEndPatternLength == endPatternLength, "")
        
    }
    
}
