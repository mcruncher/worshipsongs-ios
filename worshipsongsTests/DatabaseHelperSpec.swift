//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
@testable import worshipsongs

class DatabaseHelperSepc : QuickSpec {
    override func spec() {
        describe("DatabaseHelper") {
            let databaseHelper = DatabaseHelper()
                        
            describe("Find songs by title") {
                it("should return the list of songs matching the given title") {
                    let result = databaseHelper.findSongs(byTitle: "Amazing")
                    
                    expect(result.count).to(equal(3))
                    expect(result[0].title).to(equal("Amazing Grace (my chains are gone)"))
                }
            }
            
            describe("Find authors by song id") {
                let songs = databaseHelper.findSongs(byTitle: "God is good all the time")

                it("should fetch the first available author for the song") {
                    let authors = databaseHelper.findAuthors(bySongId: songs[0].id)
                    
                    expect(authors.count).to(equal(2))
                    expect(authors[0]).to(equal("Don Moen"))
                    expect(authors[1]).to(equal("Paul Overstreet"))
                }
            }
        }
    }
}
