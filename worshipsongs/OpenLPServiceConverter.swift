//
// Author: James Selvakumar
// Since: 3.0.0
// Ref: https://gitlab.com/openlp/openlp/-/blob/master/openlp/core/lib/serviceitem.py
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import SwiftyJSON

class OpenLPServiceConverter : IOpenLPServiceConverter {
    private let databaseHelper = DatabaseHelper()
    
    func toOszlJson(favouriteList: [FavoritesSongsWithOrder]) -> JSON {
        var openLPService = [getGeneralServiceInfo()]
        for favouriteSong in favouriteList {
            let songs = databaseHelper.findSongsByTitles([favouriteSong.songName])
            for song in songs {
                let authors = databaseHelper.findAuthors(bySongId: song.id)
                openLPService.append(getServiceItem(forSong: song, forAuthors: authors))
            }
        }
        return JSON(openLPService)
    }
    
    private func getGeneralServiceInfo() -> [String: Any?] {
        let openLPCoreInfo = ["lite_service": true, "service_theme": ""] as [String: Any?]
        let generalServiceInfo = ["openlp_core": openLPCoreInfo] as [String: Any?]
        return generalServiceInfo
    }
    
    private func getServiceItem(forSong song: Songs, forAuthors authors: [String]) -> [String: Any?] {
        let serviceItem = ["serviceitem": getServiceItemHeader(forSong: song, forAuthors: authors)] as [String: Any?]
        return serviceItem
    }
            
    private func getServiceItemHeader(forSong song: Songs, forAuthors authors: [String]) -> [String: Any?] {
        let serviceItemHeaderContent  = [
            "name": "songs",
            "plugin": "songs",
            "theme": NSNull(),
            "title": song.title,
            "footer": getFooter(forSong: song),
            "type": 1, // not sure what is this, need to check OpenLP docs
            "icon": ":/plugins/plugin_songs.png",
            "audit": getAudit(forSong: song, forAuthors: authors),
            "notes": "",
            "from_plugin": false,
            "capabilities": [2, 1, 5, 8, 9, 13], // not sure what is this, need to check OpenLP docs
            "search": "",
            "data": getData(forSong: song, forAuthors: authors),
            "xml_version": getXmlVersion(ofSong: song),
            "auto_play_slides_once": false,
            "auto_play_slides_loop": false,
            "timed_slide_interval": 0,
            "start_time": 0,
            "end_time": 0,
            "media_length": 0,
            "background_audio": [],
            "theme_overwritten": false,
            "will_auto_start": false,
            "processor": NSNull()
        ] as [String : Any?]
        
        let serviceItemHeader = [
            "header": serviceItemHeaderContent
        ] as [String: Any?]
        return serviceItemHeader
    }
    
    private func getFooter(forSong song: Songs) -> [String] {
        let footer = [song.title, "Written by: \(databaseHelper.findAuthor(bySongId: song.id))"]
        return footer
    }
    
    private func getAudit(forSong song: Songs, forAuthors authors: [String]) -> [Any] {
        let audit = [song.title, authors, "", ""] as [Any]
        return audit
    }
    
    private func getData(forSong song: Songs, forAuthors authors: [String]) -> [String : String] {
        let data = [
            "title": "\(song.title.withoutSpecialCharacters.lowercased())@\(song.alternateTitle.withoutSpecialCharacters.lowercased())",
            "authors": authors.joined(separator: ", ")
        ]
        return data
    }
    
    private func getXmlVersion(ofSong song: Songs) -> String {
        return ""
    }
}
