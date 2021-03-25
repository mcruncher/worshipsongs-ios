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

class OpenLPServiceConverterSpec : QuickSpec {
    override func spec() {
            let openLPServiceConverter = OpenLPServiceConverter()
            let databaseHelper = DatabaseHelper()
            var song1: Songs!
            
            beforeEach {
                song1 = databaseHelper.findSongs(byTitle: "Amazing Grace")[0]
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
                    result = openLPServiceConverter.getXmlVersion(forSong: song1, withAuthors: databaseHelper.findAuthors(bySongId: song1.id))
                    print(result.xml)
                }
                                
                it("should have the required attributes in the 'song' element") {
                    let attributes = result.root.attributes
                    
                    expect(attributes["xmlns"]).to(equal("http://openlyrics.info/namespace/2009/song"))
                    expect(attributes["version"]).to(equal("0.8"))
                    expect(attributes["createdIn"]).to(equal("OpenLP 2.4.6"))
                    expect(attributes["modifiedIn"]).to(equal("OpenLP 2.4.6"))
//                    expect(attributes["modifiedDate"]).to(equal("2021-01-01T09:00:00"))
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
                    expect(themes.children[0].value).to(equal("English {ஆங்கிலம்}"))
                    expect(themes.children.count).to(equal(1))
                    
                    expect(properties.children.count).to(equal(4))
                }
                
                it("should have a lyrics element with respective child elements") {
                    let lyrics = result.root["lyrics"]
                    print(song1.lyrics)
                    
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
    }
}
