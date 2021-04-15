//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
@testable import worshipsongs

class StringExtensionsSpec : QuickSpec {
    override func spec() {        
        describe("To ascii") {
            it("should encode unicode chars using appropriate unicode code points") {
                expect("foo".toAscii()).to(equal("foo"))
                expect("English {ஆங்கிலம்}".toAscii()).to(equal("English {\\u0b86\\u0b99\\u0bcd\\u0b95\\u0bbf\\u0bb2\\u0bae\\u0bcd}"))
            }
        }
    }
}
