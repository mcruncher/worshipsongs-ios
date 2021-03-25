//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SwiftyJSON
import AEXML
@testable import worshipsongs

class ConvertFavouritesToOpenLPServiceAcceptanceSpec : QuickSpec {
    override func spec() {
        let openLPServiceConverter = OpenLPServiceConverter()
        let databaseHelper = DatabaseHelper()
        var favouriteList: [FavoritesSongsWithOrder]!
        var song1: Songs!
        var song2: Songs!
        var expectedJson: JSON!
        var result: JSON!
        
        beforeEach {
            song1 = databaseHelper.findSongs(byTitle: "Amazing Grace")[0]
            song2 = databaseHelper.findSongs(byTitle: "God is good")[0]
        }
        
        describe("Convert favourite list to OpenLP Service Lite JSON format") {
            context("given a favourite list exist with some songs") {
                beforeEach {
                    let favouriteSong1 = FavoritesSongsWithOrder(orderNo: 1, songName: song1.title, songListName: "foo")
                    let favouriteSong2 = FavoritesSongsWithOrder(orderNo: 2, songName: song2.title, songListName: "foo")
                    favouriteList = [favouriteSong1, favouriteSong2]
                }
                
                context("and a oszl (OpenLP Service Lite) json generated by OpenLP exists for the same songs in the same order") {
                    beforeEach {
                        let bundle = Bundle(for: type(of: self))
                        let path = bundle.path(forResource: "openlp-service-lite", ofType: "osj")!
                        let jsonData = NSData(contentsOfFile: path)!
                        expectedJson = try! JSON(data: jsonData as Data)
                        print("Expected Json:\n \(expectedJson)")
                    }
                    
                    context("when converting the favourite list to oszl json format") {
                        beforeEach {
                            result = openLPServiceConverter.toOszlJson(favouriteList: favouriteList!)
                            print("Result: \(result.rawValue)")
                        }
                        
                        it("should have a top level array with three elements") {
                            expect(result.count).to(equal(expectedJson.count))
                        }
                        
                        it("should have general service info as the first element of the array") {
                            let generalServiceInfo = result[0]
                            let openlpCore = generalServiceInfo["openlp_core"]
                            
                            expect(openlpCore["lite_service"].bool).to(beTrue())
                            expect(openlpCore["service_theme"]).to(beEmpty())
                        }
                        
                        it("should have a service header for the first song") {
                            let expectedSongTitle = "Amazing Grace (my chains are gone)"
                            let expectedAuthor = "John Newton"
                            
                            let serviceItem = result[1]["serviceitem"]
                            let serviceItemHeader = serviceItem["header"]
                            
                            print("No. of elements in service item header: \(serviceItemHeader.count)")
                            expect(serviceItemHeader.count).to(equal(expectedJson[1]["serviceitem"]["header"].count))
                            
                            expect(serviceItemHeader["name"]).to(equal("songs"))
                            expect(serviceItemHeader["plugin"]).to(equal("songs"))
                            expect(serviceItemHeader["theme"].null).to(beAnInstanceOf(NSNull.self))
                            expect(serviceItemHeader["title"].string).to(equal(expectedSongTitle))
                            
                            let footer = serviceItemHeader["footer"]
                            expect(footer.count).to(equal(2))
                            expect(footer[0].string).to(equal(expectedSongTitle))
                            expect(footer[1].string).to(equal("Written by: \(expectedAuthor)"))
                            
                            expect(serviceItemHeader["type"]).to(equal(1))
                            expect(serviceItemHeader["icon"]).to(equal(":/plugins/plugin_songs.png"))
                            
                            let audit = serviceItemHeader["audit"]
                            expect(audit.count).to(equal(4))
                            expect(audit[0].string).to(equal(expectedSongTitle))
                            expect(audit[1]).to(equal(["\(expectedAuthor)"]))
                            expect(audit[2]).to(equal(""))
                            expect(audit[3]).to(equal(""))
                            
                            expect(serviceItemHeader["notes"]).to(equal(""))
                            expect(serviceItemHeader["from_plugin"].bool).to(beFalse())
                            expect(serviceItemHeader["capabilities"]).to(equal([2, 1, 5, 8, 9, 13]))
                            expect(serviceItemHeader["search"]).to(equal(""))
                            
                            let data = serviceItemHeader["data"]
                            let expectedDataTitle = "amazing grace my chains are gone@unending love amazing grace"
                            expect(data.count).to(equal(2))
                            expect(data["title"].string).to(equal(expectedDataTitle))
                            expect(data["authors"].string).to(equal(expectedAuthor))
                            
                            let expectedXmlVersion = expectedJson[1]["serviceitem"]["header"]["xml_version"].string
//                            expect(serviceItemHeader["xml_version"].string).to(equal(expectedXmlVersion))
                            
                            expect(serviceItemHeader["auto_play_slides_once"].bool).to(beFalse())
                            expect(serviceItemHeader["auto_play_slides_loop"].bool).to(beFalse())
                            expect(serviceItemHeader["timed_slide_interval"]).to(equal(0))
                            expect(serviceItemHeader["start_time"]).to(equal(0))
                            expect(serviceItemHeader["end_time"]).to(equal(0))
                            expect(serviceItemHeader["media_length"]).to(equal(0))
                            expect(serviceItemHeader["background_audio"]).to(equal([]))
                            expect(serviceItemHeader["theme_overwritten"].bool).to(beFalse())
                            expect(serviceItemHeader["will_auto_start"].bool).to(beFalse())
                            expect(serviceItemHeader["processor"].null).to(beAnInstanceOf(NSNull.self))
                        }
                        
                        it("should have a data element for the first song") {
                            let data = result[1]["serviceitem"]["data"]
                            print("Data: \(data)")
                            
                            expect(data.count).to(equal(8))
                            expect(data[0]["title"].string).toNot(beEmpty())
                            expect(data[0]["verseTag"].string).to(equal("V1"))
                            expect(data[0]["raw_slide"].string).toNot(beEmpty())
                            
                            expect(data[7]["title"].string).toNot(beEmpty())
                            expect(data[7]["verseTag"].string).to(equal("B1"))
                            expect(data[7]["raw_slide"].string).toNot(beEmpty())
                        }
                        
                        it("should have a service header for the second song") {
                            let expectedSongTitle = "God Is Good All The Time"
                            let expectedAuthor1 = "Don Moen"
                            let expectedAuthor2 = "Paul Overstreet"
                            
                            let serviceItem = result[2]["serviceitem"]
                            let serviceItemHeader = serviceItem["header"]
                            
                            print("No. of elements in service item header: \(serviceItemHeader.count)")
                            expect(serviceItemHeader.count).to(equal(expectedJson[1]["serviceitem"]["header"].count))
                            
                            expect(serviceItemHeader["name"]).to(equal("songs"))
                            expect(serviceItemHeader["plugin"]).to(equal("songs"))
                            expect(serviceItemHeader["theme"].null).to(beAnInstanceOf(NSNull.self))
                            expect(serviceItemHeader["title"].string).to(equal(expectedSongTitle))
                            
                            let footer = serviceItemHeader["footer"]
                            expect(footer.count).to(equal(2))
                            expect(footer[0].string).to(equal(expectedSongTitle))
                            expect(footer[1].string).to(equal("Written by: \(expectedAuthor1) and \(expectedAuthor2)"))
                            
                            expect(serviceItemHeader["type"]).to(equal(1))
                            expect(serviceItemHeader["icon"]).to(equal(":/plugins/plugin_songs.png"))
                            
                            let audit = serviceItemHeader["audit"]
                            expect(audit.count).to(equal(4))
                            expect(audit[0].string).to(equal(expectedSongTitle))
                            expect(audit[1]).to(equal([expectedAuthor1, expectedAuthor2]))
                            expect(audit[2]).to(equal(""))
                            expect(audit[3]).to(equal(""))
                            
                            expect(serviceItemHeader["notes"]).to(equal(""))
                            expect(serviceItemHeader["from_plugin"].bool).to(beFalse())
                            expect(serviceItemHeader["capabilities"]).to(equal([2, 1, 5, 8, 9, 13]))
                            expect(serviceItemHeader["search"]).to(equal(""))
                            
                            let data = serviceItemHeader["data"]
                            let expectedDataTitle = "god is good all the time@god is good all the time"
                            expect(data.count).to(equal(2))
                            expect(data["title"].string).to(equal(expectedDataTitle))
                            expect(data["authors"].string).to(equal("Don Moen, Paul Overstreet"))
                            
//                            expect(serviceItemHeader["xml_version"].string).to(equal())
                            
                            expect(serviceItemHeader["auto_play_slides_once"].bool).to(beFalse())
                            expect(serviceItemHeader["auto_play_slides_loop"].bool).to(beFalse())
                            expect(serviceItemHeader["timed_slide_interval"]).to(equal(0))
                            expect(serviceItemHeader["start_time"]).to(equal(0))
                            expect(serviceItemHeader["end_time"]).to(equal(0))
                            expect(serviceItemHeader["media_length"]).to(equal(0))
                            expect(serviceItemHeader["background_audio"]).to(equal([]))
                            expect(serviceItemHeader["theme_overwritten"].bool).to(beFalse())
                            expect(serviceItemHeader["will_auto_start"].bool).to(beFalse())
                            expect(serviceItemHeader["processor"].null).to(beAnInstanceOf(NSNull.self))
                        }
                        
                        it("should have a data element for the second song") {
                            let data = result[2]["serviceitem"]["data"]
                            print("Data: \(data)")
                            
                            expect(data.count).to(equal(13))
                            expect(data[0]["title"].string).toNot(beEmpty())
                            expect(data[0]["verseTag"].string).to(equal("C1"))
                            expect(data[0]["raw_slide"].string).toNot(beEmpty())
                            
                            expect(data[12]["title"].string).toNot(beEmpty())
                            expect(data[12]["verseTag"].string).to(equal("C2"))
                            expect(data[12]["raw_slide"].string).toNot(beEmpty())
                        }

                    }
                }
            }
        }
    }
}
