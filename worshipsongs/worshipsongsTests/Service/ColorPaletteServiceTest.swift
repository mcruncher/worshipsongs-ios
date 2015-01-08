//
//  ColorPaletteServiceTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/8/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import XCTest
import UIKit

class ColorPaletteServiceTest: XCTestCase {
    let colorPaletteService: ColorPaletteService = ColorPaletteService()
    var paletteValue: Array<String> = Array()
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let path = NSBundle.mainBundle().pathForResource("colorPalette", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path!)
        if let colorPalettePlistFile = pListArray {
            paletteValue = colorPalettePlistFile as [String]
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetColorPalette(){
        var colorPallete: Array<String> = colorPaletteService.getColorPalette()
        XCTAssertTrue(colorPallete.count == paletteValue.count, "")
    }
    
    func testHexStringToUIColor(){
        var color = colorPaletteService.hexStringToUIColor(paletteValue[0])
        print("uicolor:\(color)")
        var expectedColor = UIColor(red:1,green:1,blue:1,alpha:1)
        XCTAssertEqual(color, expectedColor, "")
    }

}
