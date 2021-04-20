//
// Author: James Selvakumar
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
@testable import worshipsongs

class TitlesViewModelSpec : QuickSpec {
    override func spec() {
        var titlesViewModel: TitlesViewModel!
        let preferences = UserDefaults.standard
        
        beforeEach {
            titlesViewModel = TitlesViewModel()
        }
        
        afterEach {
            preferences.removeObject(forKey: "language")
            preferences.removeObject(forKey: "searchBy")
        }
        
        describe("Get title cell text") {
            var song: Song!
            
            context("given the app is not configured to display i8nTitle") {
                
                context("given a song exists with i18nTitle") {
                    
                    beforeEach {
                        song = Song()
                        song.title = "foo"
                        song.i18nTitle = "bar"
                    }
                    
                    it("should be the title") {
                        expect(titlesViewModel.getTitleCellText(forSong: song)).to(equal(song.title))
                    }
                }
                
                context("given a song exists with no i18nTitle") {
                    
                    beforeEach {
                        song = Song()
                        song.title = "foo"
                    }
                    
                    it("should be the title") {
                        expect(titlesViewModel.getTitleCellText(forSong: song)).to(equal(song.title))
                    }
                }
            }
            
            context("given the app is configured to display i8nTitle") {
                
                beforeEach {
                    preferences.setValue("tamil", forKey: "language")
                }
                
                context("given a song exists with i18nTitle") {
                    
                    beforeEach {
                        song = Song()
                        song.title = "foo"
                        song.i18nTitle = "bar"
                    }
                    
                    it("should be the i18nTitle") {
                        expect(titlesViewModel.getTitleCellText(forSong: song)).to(equal(song.i18nTitle))
                    }
                }
                
                context("given a song exists with no i18nTitle") {
                    
                    beforeEach {
                        song = Song()
                        song.title = "foo"
                    }
                    
                    it("should be the title") {
                        expect(titlesViewModel.getTitleCellText(forSong: song)).to(equal(song.title))
                    }
                }
            }
            
        }
        
        describe("Should play image be hidden") {
            var song: Song!
            
            context("given a song exists without a mediaUrl") {
                
                beforeEach {
                    song = Song()
                }
                
                it("should be hidden") {
                    expect(titlesViewModel.shouldPlayImageBeHidden(forSong: song)).to(beTrue())
                }
            }
            
            context("given a song exists without a mediaUrl") {
                
                beforeEach {
                    song = Song()
                    song.mediaUrl = "foo"
                }
                
                it("should be hidden") {
                    expect(titlesViewModel.shouldPlayImageBeHidden(forSong: song)).to(beFalse())
                }
            }
        }
        
        describe("Is language set?") {
            context("given the language is not set") {
                it("should be false") {
                    expect(titlesViewModel.isLanguageSet()).to(beFalse())
                }
            }
            
            context("given the language is set") {
                
                beforeEach {
                    preferences.setValue("foo", forKey: "language")
                }
                
                it("should be true") {
                    expect(titlesViewModel.isLanguageSet()).to(beTrue())
                }
            }
        }
        
        describe("Filter songs by search text") {
            var songs: [Song]!
            let expectedSongTitle = "Siluvai Sumantha Uruvam"
            
            context("given a song exists with the title: 'Siluvai Sumantha Uruvam', alternate title: 'Siluvai Sumandha' and i18nTitle: 'சிலுவை சுமந்த உருவம்'") {
            
                beforeEach {
                    songs = DatabaseHelper().findSongs()
                }
                
                context("and the user searches by title") {
                    context("when the user searches by the text 'Sumantha'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "Sumantha").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }
                    
                    context("when the user searches by the text 'Sumandha'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "Sumandha").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }
                    
                    context("when the user searches by the text 'சுமந்த'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "சுமந்த").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }
                }
                
                context("and the user searches by content") {
                    
                    beforeEach {
                        preferences.setValue("searchByContent", forKey: "searchBy")
                    }
                    
                    context("when the user searches by the text 'Sumantha'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "Sumantha").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }
                    
                    context("when the user searches by the text 'Sumandha'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "Sumandha").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }
                    
                    context("when the user searches by the text 'சுமந்த'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "சுமந்த").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }
                    
                    context("when the user searches by the text 'Parigaari'") {
                        it("should contain the respective song in the search result") {
                            let result = titlesViewModel.filter(songs: songs, bySearchText: "Parigaari").map {$0.title}
                            
                            expect(result).to(contain(expectedSongTitle))
                        }
                    }

                }
 
            }
        }
    }
}
