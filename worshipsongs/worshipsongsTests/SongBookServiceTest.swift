
//
// author: Madasamy
// version: 2.3.0
//

import XCTest
@testable import worshipsongs

class SongBookServiceTest: XCTestCase {
    
    private let songBookService = SongBookService()
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetTamilName() {
        XCTAssertEqual("நன்றி", songBookService.getTamilName("foo{நன்றி}"))
    }
    
    func testGetEnglishName() {
        let name = "foo{bar}"
        XCTAssertEqual("foo", songBookService.getEnglishName(name))
    }
    
    
}
