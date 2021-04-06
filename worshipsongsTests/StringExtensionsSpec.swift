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
        describe("Without special characters") {
            it("should not have symbols") {
                expect("foo$".withoutSpecialCharacters).to(equal("foo"))
                expect("foo$+=*%/@bar".withoutSpecialCharacters).to(equal("foobar"))
            }
            
            it("should not have punctuation characters") {
                expect("(f_o-o.b,a'r;:?)[]{}!".withoutSpecialCharacters).to(equal("foobar"))
//                expect("foo&bar".withoutSpecialCharacters).to(equal("foobar"))
            }
        }
        
        describe("To ascii") {
            it("should encode unicode chars using appropriate unicode code points") {
                expect("foo".toAscii()).to(equal("foo"))
                expect("English {ஆங்கிலம்}".toAscii()).to(equal("English {\\u0b86\\u0b99\\u0bcd\\u0b95\\u0bbf\\u0bb2\\u0bae\\u0bcd}"))
            }
        }
    }
}
