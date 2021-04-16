//
// Author: James Selvakumar
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation

class TitlesViewModel {
    
    private let preferences = UserDefaults.standard
    
    func getTitleCellText(forSong song: Songs) -> String {
        if !song.i18nTitle.isEmpty {
            return song.i18nTitle
        }
        return song.title
    }
    
    func shouldPlayImageBeHidden(forSong song: Songs) -> Bool {
        return song.mediaUrl.isEmpty
    }
    
    func isLanguageSet() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("language")
    }
    
    func isLanguageTamil() -> Bool {
        return preferences.string(forKey: "language") == "tamil"
    }
}
