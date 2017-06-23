//
// @author: Vignesh palanisamy
// @version: 1.0.0
//

import Foundation



class Songs {
    var id = ""
    var title = ""
    var lyrics = ""
    var verse_order = ""
    var comment = ""
    var i18nTitle = ""
    var mediaUrl = ""
    
    init(id: String, title: String, lyrics: String, verse_order: String, comment: String) {
        self.id = id
        self.title = title
        self.lyrics = lyrics
        self.verse_order = verse_order
        self.comment = comment
        self.i18nTitle = getI18nTitle(comment: comment)
        self.mediaUrl = getMediaUrl(comment: comment)
    }
    
    init() {
        self.id = ""
        self.title = ""
        self.lyrics = ""
        self.verse_order = ""
        self.comment = ""
        self.i18nTitle = ""
        self.mediaUrl = ""
    }
    
    private func getI18nTitle(comment: String) -> String {
        let properties = comment.components(separatedBy: "\n")
        for property in properties {
            if property.contains("i18nTitle"){
                return property.components(separatedBy: "=")[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
    
    private func getMediaUrl(comment: String) -> String {
        let properties = comment.components(separatedBy: "\n")
        for property in properties {
            if property.contains("mediaUrl"){
                return property.components(separatedBy: "Url=")[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
    
    
}
