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
            
            describe("Find author by song id") {
                let songs = databaseHelper.getSongModel()

                it("should fetch the first available author for the song") {
                    expect(databaseHelper.findAuthor(bySongId: songs[0].id)).to(equal("Fr. S. J. Berchmans {பெர்க்மான்ஸ்}"))
                }
            }
            
            describe("Find songs by title") {
                it("should return the list of songs matching the given title") {
                    let result = databaseHelper.findSongs(byTitle: "Amazing")
                    
                    expect(result.count).to(equal(2))
                    expect(result[0].title).to(equal("Amazing Grace (my chains are gone)"))
                }
            }
        }
    }
}
