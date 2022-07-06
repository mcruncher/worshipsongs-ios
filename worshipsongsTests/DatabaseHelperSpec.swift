//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
import FMDB
@testable import worshipsongs

class DatabaseHelperSepc : QuickSpec {
    override func spec() {
        describe("DatabaseHelper") {
            let databaseHelper = DatabaseHelper()
            
            describe("Find songs") {
                it("should return all the songs in the database ordered by title") {
                    let result = databaseHelper.findSongs()
                    
                    expect(result.count).to(beGreaterThan(1300))
                }
            }
            
            describe("Find songs by author id") {
                it("should return the songs matching the given author id") {
                    let authors = databaseHelper.findAuthors()
                    let result = databaseHelper.findSongs(byAuthorId: authors[0].id)
                    
                    expect(result.count).to(beGreaterThan(0))
                }
            }
            
            describe("Find songs by category id") {
                it("should return the songs matching the given category id") {
                    let categories = databaseHelper.findCategories()
                    let result = databaseHelper.findSongs(byCategoryId: categories[0].id)
                    
                    expect(result.count).to(beGreaterThan(0))
                }
            }
            
            describe("Find songs by title") {
                it("should return the list of songs matching the given title") {
                    let result = databaseHelper.findSongs(byTitle: "Amazing")
                    
                    expect(result.count).to(equal(3))
                    expect(result[0].title).to(equal("Amazing Grace (my chains are gone)"))
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    expect(result[0].lastModified).to(equal(dateFormatter.date(from: "2022-07-06 07:15:33")))
                }
            }
            
            describe("Find songs by titles") {
                it("should return the songs matching the given titles") {
                    let songs = databaseHelper.findSongs()
                    let result = databaseHelper.findSongs(byTitles: [songs[0].title, songs[1].title])
                    
                    expect(result.count).to(equal(2))
                }
            }
            
            describe("Find songs by song ids") {
                it("should return the songs matching the given song ids") {
                    let songs = databaseHelper.findSongs()
                    let result = databaseHelper.findSongs(bySongIds: [songs[0].id, songs[1].id])
                    
                    expect(result.count).to(equal(2))
                }
            }
            
            describe("Find authors") {
                it("should return all the authors in the database") {
                    let result = databaseHelper.findAuthors()
                    
                    expect(result.count).to(beGreaterThan(1))
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
            
            describe("Find categories") {
                it("should return all the categories") {
                    let result = databaseHelper.findCategories()
                    
                    expect(result.count).to(beGreaterThan(1))
                }
            }
            
            describe("Find categories by song id") {
                let songs = databaseHelper.findSongs(byTitle: "God is good all the time")
                
                it("should fetch all the topics for a given song") {
                    let categories = databaseHelper.findCategories(bySongId: songs[0].id)
                    
                    expect(categories.count).to(equal(1))
                    expect(categories[0]).to(equal("English {ஆங்கிலம்}"))
                }
            }
            
            describe("Get song") {
                var commonService: CommonService!
                var database: FMDatabase!
                var songs: [Song]!
                var arguments: [AnyObject]!
                var resultSet: FMResultSet!
                
                beforeEach {
                    commonService = CommonService()
                    songs = [Song]()
                    arguments = [AnyObject]()

                    database = FMDatabase(path: commonService.getDocumentDirectoryPath(databaseHelper.dbName))
                    database.open()
                }
                
                context("when constructing a song object for a song which does not have a i18nTitle") {
                    beforeEach {
                        resultSet = database.executeQuery("SELECT * FROM songs WHERE verse_order != '' AND comments = '' ORDER BY title", withArgumentsIn: arguments)
                        while resultSet!.next() {
                            songs.append(databaseHelper.getSong(fromResultSet: resultSet!))
                        }
                    }
                    
                    it("should construct a song object with all the necessary attributes") {
                        
                        expect(songs[0].id).toNot(beEmpty())
                        expect(songs[0].title).toNot(beEmpty())
                        expect(songs[0].lyrics).toNot(beEmpty())
                        expect(songs[0].verseOrder).toNot(beEmpty())
                        expect(songs[0].lastModified).toNot(beNil())
                        
                        expect(songs[0].i18nTitle).to(beEmpty())
                        expect(songs[0].comment).to(beEmpty())
                    }
                }
                
                context("when constructing a song object for a song which has an i18nTitle and mediaurl") {
                    beforeEach {
                        resultSet = database.executeQuery("SELECT * FROM songs WHERE verse_order != '' AND comments LIKE 'i18n%' ORDER BY title", withArgumentsIn: arguments)
                        while resultSet!.next() {
                            songs.append(databaseHelper.getSong(fromResultSet: resultSet!))
                        }
                    }
                    
                    it("should construct a song object with all the necessary attributes") {
                        
                        expect(songs[0].id).toNot(beEmpty())
                        expect(songs[0].title).toNot(beEmpty())
                        expect(songs[0].lyrics).toNot(beEmpty())
                        expect(songs[0].verseOrder).toNot(beEmpty())
                        expect(songs[0].lastModified).toNot(beNil())
                        
                        expect(songs[0].comment).toNot(beEmpty())
                        expect(songs[0].i18nTitle).toNot(beEmpty())
                        expect(songs[0].mediaUrl).toNot(beEmpty())
                    }
                }
            }
        }
    }
}
