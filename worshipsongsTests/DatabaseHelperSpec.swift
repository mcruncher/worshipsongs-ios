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

                it("should fetch all the authors for a given song") {
                    let authors = databaseHelper.findAuthors(bySongId: songs[0].id)
                    
                    expect(authors.count).to(equal(2))
                    expect(authors[0]).to(equal("Don Moen"))
                    expect(authors[1]).to(equal("Paul Overstreet"))
                }
            }
            
            describe("Find topics by song id") {
                let songs = databaseHelper.findSongs(byTitle: "God is good all the time")
                
                it("should fetch all the topics for a given song") {
                    let categories = databaseHelper.findTopics(bySongId: songs[0].id)
                                        
                    expect(categories.count).to(equal(1))
                    expect(categories[0]).to(equal("English {ஆங்கிலம்}"))
                }
            }
        }
    }
}
