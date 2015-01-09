//
//  UserDefaultsSettingsProviderServiceTest.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 1/9/15.
//  Copyright (c) 2015 Seenivasan Sankaran. All rights reserved.
//

import UIKit
import XCTest

class UserDefaultsSettingsProviderServiceTest: XCTestCase {
    
    let userDefaultsSettingsProviderService:UserDefaultsSettingsProviderService = UserDefaultsSettingsProviderService()

    func testGetUserDefaultFont() {
        println("--testGetUserDefaultFont--")
        var font = userDefaultsSettingsProviderService.getUserDefaultFont()
        XCTAssertNotNil(font, "Font value not nil")
    }
    
    func testKeepAwakeScreenDisplayStatus() {
        println("--testKeepAwakeScreenDisplayStatus--")
        var keepAwakeScreenDisplayStatus = userDefaultsSettingsProviderService.keepAwakeScreenDisplayStatus()
        XCTAssertNotNil(keepAwakeScreenDisplayStatus, "KeepAwakeScreenDisplayStatus value not nil")
    }
    
    func testGetUserDefaultsColor() {
        println("--testGetUserDefaultsColor--")
        var userDefaultColor = userDefaultsSettingsProviderService.getUserDefaultsColor("secondaryFontColor")
        XCTAssertNotNil(userDefaultColor, "userDefaultColor value not nil")
    }
}
