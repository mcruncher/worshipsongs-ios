//
// Author: James Selvakumar
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation

class TitlesViewModel {
    
    private let preferences = NSUbiquitousKeyValueStore.default
    
    func getTitleCellText(forSong song: Song) -> String {
        if isLanguageTamil() && !song.i18nTitle.isEmpty {
            return song.i18nTitle
        }
        return song.title
    }
    
    func shouldPlayImageBeHidden(forSong song: Song) -> Bool {
        return song.mediaUrl.isEmpty
    }
    
    func filter(songs: [Song], bySearchText searchText: String) -> [Song] {
        var filteredSongs = songs
        if searchText.count > 0 {
            filteredSongs = songs.filter({( song: Song) -> Bool in
                if isSearchByContent() {
                    let stringMatch = song.title.localizedCaseInsensitiveContains(searchText) ||
                        song.alternateTitle.localizedCaseInsensitiveContains(searchText) || 
                        song.comment.localizedCaseInsensitiveContains(searchText) ||
                        song.lyrics.localizedCaseInsensitiveContains(searchText)
                    return (stringMatch)
                } else {
                    let stringMatch = song.title.localizedCaseInsensitiveContains(searchText) ||
                        song.alternateTitle.localizedCaseInsensitiveContains(searchText) ||
                        song.comment.localizedCaseInsensitiveContains(searchText)
                    return (stringMatch)
                }
            })
        }
        return filteredSongs
    }
    
    func isLanguageSet() -> Bool {
        return preferences.dictionaryRepresentation.keys.contains("language")
    }
    
    func isLanguageTamil() -> Bool {
        return preferences.string(forKey: "language") == "tamil"
    }
    
    func isSearchByContent() -> Bool {
        return self.preferences.string(forKey: "searchBy") == "searchByContent"
    }
}
