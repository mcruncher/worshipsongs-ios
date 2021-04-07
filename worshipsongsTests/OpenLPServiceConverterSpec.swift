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
import Zip
@testable import worshipsongs

class OpenLPServiceConverterSpec : QuickSpec {
    override func spec() {
        let openLPServiceConverter = OpenLPServiceConverter()
        let databaseHelper = DatabaseHelper()
        var song: Songs!
        
        beforeEach {
            song = databaseHelper.findSongs(byTitle: "Amazing Grace")[0]
        }
        
        
        describe("Get footer authors") {
            it("should be in the expected format") {
                expect(openLPServiceConverter.getFooterAuthors(["foo"])).to(equal("Written by: foo"))
                expect(openLPServiceConverter.getFooterAuthors(["foo", "bar"])).to(equal("Written by: foo and bar"))
                expect(openLPServiceConverter.getFooterAuthors(["foo", "bar", "foobar"])).to(equal("Written by: foo, bar and foobar"))
            }
        }
        
        describe("Get xml version of song") {
            var result: AEXMLDocument!
            
            beforeEach {
                result = openLPServiceConverter.getXmlVersion(forSong: song, withAuthors: databaseHelper.findAuthors(bySongId: song.id))
                print("Result xml: \n \(result.xmlCompact)")
            }
            
            it("should have the required attributes in the 'song' element") {
                let attributes = result.root.attributes
                
                expect(attributes["xmlns"]).to(equal("http://openlyrics.info/namespace/2009/song"))
                expect(attributes["version"]).to(equal("0.8"))
                expect(attributes["createdIn"]).to(equal("OpenLP 2.4.6"))
                expect(attributes["modifiedIn"]).to(equal("OpenLP 2.4.6"))
                expect(attributes["modifiedDate"]).to(equal("2021-03-19T08:32:37"))
            }
            
            it("should have a properties element with respective child elements") {
                let properties = result.root["properties"]
                
                let titles = properties["titles"]
                expect(titles.children[0].value).to(equal("Amazing Grace (my chains are gone)"))
                expect(titles.children[1].value).to(equal("unending love, amazing grace"))
                expect(titles.children.count).to(equal(2))
                
                expect(properties["verseOrder"].value).to(equal("v1 v2 c1 c2 v3 c1 c2 b1"))
                
                let authors = properties["authors"]
                expect(authors.children[0].value).to(equal("John Newton"))
                expect(authors.children.count).to(equal(1))
                
                let themes = properties["themes"]
                expect(themes.children[0].value).to(equal("English {\\u0b86\\u0b99\\u0bcd\\u0b95\\u0bbf\\u0bb2\\u0bae\\u0bcd}"))
                expect(themes.children.count).to(equal(1))
                
                expect(properties.children.count).to(equal(4))
            }
            
            it("should have a lyrics element with respective child elements") {
                let lyrics = result.root["lyrics"]
                print(song.lyrics)
                
                let expectedVerse1Lines = "Amazing Grace! how sweet the sound<br/>That saved a wretch like me;<br/>I once was lost, but now am found,<br/>Was blind, but now I see."
                expect(lyrics.children[0].attributes["name"]).to(equal("v1"))
                expect(lyrics.children[0]["lines"].value).to(equal(expectedVerse1Lines))
                
                let expectedVerse2Lines = "'Twas grace that taught my heart to fear<br/>And grace my fears relieved<br/>How precious did that grace appear<br/>The hour I first believed"
                expect(lyrics.children[1].attributes["name"]).to(equal("v2"))
                expect(lyrics.children[1]["lines"].value).to(equal(expectedVerse2Lines))
                
                let expectedChorus1Lines = "My chains are gone <br/>I've been set free<br/>My God my Saviour<br/>Has ransomed me"
                expect(lyrics.children[2].attributes["name"]).to(equal("c1"))
                expect(lyrics.children[2]["lines"].value).to(equal(expectedChorus1Lines))
                
                let expectedChorus2Lines = "And like a flood His mercy reigns<br/>Unending love amazing grace"
                expect(lyrics.children[3].attributes["name"]).to(equal("c2"))
                expect(lyrics.children[3]["lines"].value).to(equal(expectedChorus2Lines))
                
                let expectedVerse3Lines = "The Lord has promised good to me<br/>His word my hope secures<br/>He will my shield and portion be<br/>As long as life endures"
                expect(lyrics.children[4].attributes["name"]).to(equal("v3"))
                expect(lyrics.children[4]["lines"].value).to(equal(expectedVerse3Lines))
                
                let expectedBridge1Lines = "The earth shall soon dissolve like snow<br/>The sun forbear to shine<br/>But God, Who called me here below<br/>Will be forever mine<br/>Will be forever mine<br/>You are forever mine"
                expect(lyrics.children[5].attributes["name"]).to(equal("b1"))
                expect(lyrics.children[5]["lines"].value).to(equal(expectedBridge1Lines))
                
                expect(lyrics.children.count).to(equal(6))
            }
        }
        
        describe("Get data") {
            var result: [[String: String]]!
            
            beforeEach {
                result = openLPServiceConverter.getData(forSong: song)
                print(result)
            }
            
            it("should have a title with a maximum of 30 chars for each verse") {
                expect(result[0]["title"]).to(equal("Amazing Grace! how sweet the s"))
                expect(result[1]["title"]).to(equal("'Twas grace that taught my hea"))
                expect(result[2]["title"]).to(equal("My chains are gone "))
                expect(result[3]["title"]).to(equal("And like a flood His mercy rei"))
                expect(result[4]["title"]).to(equal("The Lord has promised good to "))
                expect(result[5]["title"]).to(equal("My chains are gone "))
                expect(result[6]["title"]).to(equal("And like a flood His mercy rei"))
                expect(result[7]["title"]).to(equal("The earth shall soon dissolve "))
            }
            
            it("should have respective verse tags") {
                expect(result[0]["verseTag"]).to(equal("V1"))
                expect(result[1]["verseTag"]).to(equal("V2"))
                expect(result[2]["verseTag"]).to(equal("C1"))
                expect(result[3]["verseTag"]).to(equal("C2"))
                expect(result[4]["verseTag"]).to(equal("V3"))
                expect(result[5]["verseTag"]).to(equal("C1"))
                expect(result[6]["verseTag"]).to(equal("C2"))
                expect(result[7]["verseTag"]).to(equal("B1"))
            }
            
            it("should have respective raw slides") {
                expect(result[0]["raw_slide"]).to(equal("Amazing Grace! how sweet the sound\nThat saved a wretch like me;\nI once was lost, but now am found,\nWas blind, but now I see."))
                expect(result[1]["raw_slide"]).to(equal("'Twas grace that taught my heart to fear\nAnd grace my fears relieved\nHow precious did that grace appear\nThe hour I first believed"))
                expect(result[2]["raw_slide"]).to(equal("My chains are gone \nI've been set free\nMy God my Saviour\nHas ransomed me"))
                expect(result[3]["raw_slide"]).to(equal("And like a flood His mercy reigns\nUnending love amazing grace"))
                expect(result[4]["raw_slide"]).to(equal("The Lord has promised good to me\nHis word my hope secures\nHe will my shield and portion be\nAs long as life endures"))
                expect(result[5]["raw_slide"]).to(equal("My chains are gone \nI've been set free\nMy God my Saviour\nHas ransomed me"))
                expect(result[6]["raw_slide"]).to(equal("And like a flood His mercy reigns\nUnending love amazing grace"))
                expect(result[7]["raw_slide"]).to(equal("The earth shall soon dissolve like snow\nThe sun forbear to shine\nBut God, Who called me here below\nWill be forever mine\nWill be forever mine\nYou are forever mine"))
            }
        }
        
        describe("To OpenLP Service Lite") {
            var favouriteList: [FavoritesSong]!
            let favouriteName = "foo"
            let serviceDataFilePath = SimplePDFUtilities.pathForTmpFile("service_data.osj")
            let serviceFilePath = SimplePDFUtilities.pathForTmpFile("\(favouriteName).oszl")
            
            context("given a favourite list exists") {
                
                beforeEach {
                    let songWithOrder = FavoritesSongsWithOrder(orderNo: 1, songName: song.title, songListName: "foo")
                    favouriteList = [FavoritesSong(songTitle: song.title, songs: song, favoritesSongsWithOrder: songWithOrder)]
                }
                
                context("when converting the favourite list to OpenLP Service") {
                    
                    beforeEach {
                        openLPServiceConverter.toOpenLPServiceLite(favouriteName: favouriteName, favouriteList: favouriteList)
                    }
                    
                    afterEach {
                        do {
                            try FileManager.default.removeItem(atPath: serviceFilePath)                        
                        } catch {}
                    }
                    
                    it("should be converted to OpenLP Service Lite") {
                        expect(FileManager.default.fileExists(atPath: serviceFilePath)).to(beTrue())
                        expect(FileManager.default.fileExists(atPath: serviceDataFilePath)).to(beFalse())
                    }
                    
                    it("should have a service_data.osj file inside it") {
                        do {
                            try Zip.quickUnzipFile(URL(fileURLWithPath: serviceFilePath))
                            expect(FileManager.default.fileExists(atPath: serviceDataFilePath)).to(beTrue())
                        } catch {}
                    }
                    
                }
                
            }
        }
    }
}
