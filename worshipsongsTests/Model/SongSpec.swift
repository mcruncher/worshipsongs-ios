//
// Author: Vignesh Palanisamy
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
@testable import worshipsongs

class SongSpec : QuickSpec {
    override func spec() {
        var song: Song!
        
        beforeEach {
            song = Song()
        }
        describe("Get I18n Title") {
            
            context("given a song comment exists with i18nTitle") {
                    
                    beforeEach {
                        song.comment = "i18nTitle=foo"
                    }
                    
                    it("should return i18nTitle") {
                        expect(song.getI18nTitle(comment: song.comment)).to(equal("foo"))
                    }
            }
            
            context("given a song comment don't exists with i18nTitle") {
                    
                    beforeEach {
                        song.comment = "xcadzxc=foo"
                    }
                    
                    it("should return empty string") {
                        expect(song.getI18nTitle(comment: song.comment)).to(equal(""))
                    }
            }
            
            context("given a song comment exists with i18nTitle but the seperator is missing") {
                    
                    beforeEach {
                        song.comment = "i18nTitle:foo"
                    }
                    
                    it("should return empty string") {
                        expect(song.getI18nTitle(comment: song.comment)).to(equal(""))
                    }
            }
        }
        
        describe("Get media Url") {
            
            context("given a song comment exists with media url") {
                    
                    beforeEach {
                        song.comment = "mediaUrl=foo"
                    }
                    
                    it("should return mediaUrl") {
                        expect(song.getMediaUrl(comment: song.comment)).to(equal("foo"))
                    }
            }
            
            context("given a song comment don't exists with media url") {
                    
                    beforeEach {
                        song.comment = "xcadzxc=foo"
                    }
                    
                    it("should return empty string") {
                        expect(song.getMediaUrl(comment: song.comment)).to(equal(""))
                    }
            }
            
            context("given a song comment exists with media url but the seperator is missing") {
                    
                    beforeEach {
                        song.comment = "mediaUrl:foo"
                    }
                    
                    it("should return empty string") {
                        expect(song.getMediaUrl(comment: song.comment)).to(equal(""))
                    }
            }
        }
    }
}
