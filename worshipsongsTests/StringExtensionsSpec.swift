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
    }
}
