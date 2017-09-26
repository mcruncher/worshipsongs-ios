
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
    
    func testGetNameWhenLanguageIsEgnlish() {
        let name = "foo{நன்றி}"
        let result =  songBookService.getName(name, false)
        XCTAssertEqual("foo", result)
    }
    
    func testGetNameWhenLanguageIsTamil(){
        let name = "foo{நன்றி}"
        let result =  songBookService.getName(name, true)
        XCTAssertEqual("நன்றி", result)
    }
    
    func testGetTamilName() {
        XCTAssertEqual("நன்றி", songBookService.getTamilName("foo{நன்றி}"))
    }
    
    func testGetDefaultName() {
        let name = "foo{bar}"
        XCTAssertEqual("foo", songBookService.getDefaultName(name))
    }
    
    
}
