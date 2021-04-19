//
// Author: James Selvakumar
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
@testable import worshipsongs

class LyricsXmlParserSpec : QuickSpec {
    override func spec() {
        var lyricsXmlParser: LyricsXmlParser!
        var databaseHelper: DatabaseHelper!
                
        beforeEach {
            lyricsXmlParser = LyricsXmlParser()
            databaseHelper = DatabaseHelper()
        }
        
        describe("Parse song") {
            var song: Songs!
            var listDataDictionary: NSMutableDictionary!
            var verseOrderList: NSMutableArray!
            
            context("given a song") {
                beforeEach {
                    song = databaseHelper.findSongs(byTitle: "Amazing Grace")[0]
                }
                
                context("when parsing the song") {
                    
                    beforeEach {
                        (listDataDictionary, verseOrderList) = lyricsXmlParser.parse(song: song)
                    }
                    
                    it("should have respective verses and verse order") {
                        print(verseOrderList)
                        
                        expect(verseOrderList.count).to(equal(6))
                        expect(listDataDictionary["v1"] as? String).to(contain("Was blind, but now I see"))
                    }
                }
            }
        }
    }
}
