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
        }
        
        describe("Get title cell text") {
            var song: Songs!
            
            context("given the app is not configured to display i8nTitle") {
                                                
                context("given a song exists") {
                    
                    beforeEach {
                        song = Songs()
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
                        song = Songs()
                        song.title = "foo"
                        song.i18nTitle = "bar"
                    }
                    
                    it("should be the i18nTitle") {
                        expect(titlesViewModel.getTitleCellText(forSong: song)).to(equal(song.i18nTitle))
                    }
                }
                
                context("given a song exists with no i18nTitle") {
                    
                    beforeEach {
                        song = Songs()
                        song.title = "foo"
                    }
                    
                    it("should be the title") {
                        expect(titlesViewModel.getTitleCellText(forSong: song)).to(equal(song.title))
                    }
                }
            }
            
        }
        
        describe("Should play image be hidden") {
            var song: Songs!
            
            context("given a song exists without a mediaUrl") {
                
                beforeEach {
                    song = Songs()
                }
                
                it("should be hidden") {
                    expect(titlesViewModel.shouldPlayImageBeHidden(forSong: song)).to(beTrue())
                }
            }
            
            context("given a song exists without a mediaUrl") {
                
                beforeEach {
                    song = Songs()
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
    }
}
