//
// Author: James Selvakumar
// Since: 3.0.0
// Ref: https://gitlab.com/openlp/openlp/-/blob/master/openlp/core/lib/serviceitem.py
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import SwiftyJSON
import AEXML

class OpenLPServiceConverter : IOpenLPServiceConverter {
    private let databaseHelper = DatabaseHelper()
    
    func toOpenLPServiceLite(favouriteName: String, favouriteList: [FavoritesSong]) -> URL? {
        let jsonFilePath = SimplePDFUtilities.pathForTmpFile("service_data.osj")
        let json = toOszlJson(favouriteList: favouriteList)
        do {
            let jsonString = try json.rawString(options: .init(rawValue: 0))
            print("Json string: \n \(jsonString)")
            let jsonUrl = URL(fileURLWithPath: jsonFilePath)
            try jsonString?.write(to: jsonUrl, atomically: true, encoding: .ascii)
            print("Finished writing the json to the file \(jsonFilePath)")
            return jsonUrl
        } catch {
            print("Error occurred while converting the favourite list to OpenLP Service Lite.")
            print(error)
        }
        return nil
    }
    
    func toOszlJson(favouriteList: [FavoritesSong]) -> JSON {
        var openLPService = [getGeneralServiceInfo()]
        for favouriteSong in favouriteList {
            let songs = databaseHelper.findSongsByTitles([favouriteSong.songs.title])
            for song in songs {
                let authors = databaseHelper.findAuthors(bySongId: song.id).map({$0.toAscii()})
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
        var serviceItemElements: [String: Any?] = [:]
        serviceItemElements["header"] = getHeader(forSong: song, withAuthors: authors)
        serviceItemElements["data"] = getData(forSong: song)
        
        let serviceItem = ["serviceitem": serviceItemElements]
        return serviceItem
    }
    
    private func getHeader(forSong song: Songs, withAuthors authors: [String]) -> [String: Any?] {
        let serviceItemHeaderContent  = [
            "name": "songs",
            "plugin": "songs",
            "theme": NSNull(),
            "title": song.title,
            "footer": getFooter(forSong: song, forAuthors: authors),
            "type": 1, // not sure what is this, need to check OpenLP docs
            "icon": ":/plugins/plugin_songs.png",
            "audit": getAudit(forSong: song, forAuthors: authors),
            "notes": "",
            "from_plugin": false,
            "capabilities": [2, 1, 5, 8, 9, 13], // not sure what is this, need to check OpenLP docs
            "search": "",
            "data": getHeaderData(forSong: song, forAuthors: authors),
            "xml_version": getXmlVersion(forSong: song, withAuthors: authors).xmlCompact,
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
        
        return serviceItemHeaderContent
    }
    
    private func getFooter(forSong song: Songs, forAuthors authors: [String]) -> [String] {
        let footer = [song.title, getFooterAuthors(authors)]
        return footer
    }
    
    func getFooterAuthors(_ authors: [String]) -> String {
        var formattedAuthors = ""
        if authors.count == 1 {
            formattedAuthors = authors[0]
        } else if authors.count == 2 {
            formattedAuthors = "\(authors[0]) and \(authors[1])"
        } else {
            let pneultimateIndex = authors.count - 2
            let authorsExceptTheLastOne = authors[0...pneultimateIndex]
            let formattedAuthorsExceptTheLastOne = authorsExceptTheLastOne.joined(separator: ", ")
            formattedAuthors = "\(formattedAuthorsExceptTheLastOne) and \(authors[authors.count - 1])"
        }
        return "Written by: \(formattedAuthors)"
    }
    
    private func getAudit(forSong song: Songs, forAuthors authors: [String]) -> [Any] {
        let audit = [song.title, authors, "", ""] as [Any]
        return audit
    }
    
    private func getHeaderData(forSong song: Songs, forAuthors authors: [String]) -> [String : String] {
        let data = [
            "title": "\(song.title.withoutSpecialCharacters.lowercased())@\(song.alternateTitle.withoutSpecialCharacters.lowercased())",
            "authors": authors.joined(separator: ", ")
        ]
        return data
    }
    
    func getXmlVersion(forSong song: Songs, withAuthors authors: [String]) -> AEXMLDocument {
        let root = AEXMLDocument()
        let songAttributes = ["xmlns":"http://openlyrics.info/namespace/2009/song", "version":"0.8",
                              "createdIn":"OpenLP 2.4.6", "modifiedIn":"OpenLP 2.4.6", "modifiedDate":getSongModifiedDate(song)]
        
        let songElement = root.addChild(name: "song", attributes: songAttributes)
        songElement.addChild(getPropertiesElement(forSong: song, withAuthors: authors))
        songElement.addChild(getLyricsElement(forSong: song))
        
        return root
    }
    
    private func getSongModifiedDate(_ song: Songs) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if song.lastModified != nil {
            print(song.lastModified)
            return dateFormatter.string(from: song.lastModified!)
        } else {
            return ""
        }
    }

    private func getPropertiesElement(forSong song: Songs, withAuthors authors: [String]) -> AEXMLElement {
        let propertiesElement = AEXMLElement(name: "properties")
        
        let titlesElement = propertiesElement.addChild(name: "titles")
        titlesElement.addChild(name: "title", value: song.title)
        titlesElement.addChild(name: "title", value: song.alternateTitle)
        
        let verseOrderElement = propertiesElement.addChild(name: "verseOrder", value: song.verse_order)
        
        let authorsElement = propertiesElement.addChild(name: "authors")
        for author in authors {
            authorsElement.addChild(name: "author", value: author)
        }
        
        let themesElement = propertiesElement.addChild(name: "themes")
        let topics = databaseHelper.findTopics(bySongId: song.id)
        for topic in topics {
            themesElement.addChild(name: "theme", value: topic.toAscii())
        }
        return propertiesElement
    }
    
    private func getLyricsElement(forSong song: Songs) -> AEXMLElement {
        let lyricsElement = AEXMLElement(name: "lyrics")
        do {
            let lyricsXmlDocument = try AEXMLDocument(xml: song.lyrics)
            if let verses = lyricsXmlDocument.root["lyrics"]["verse"].all {
                for verse in verses {
                    let verseType = verse.attributes["type"]!
                    let verseLabel = verse.attributes["label"]!
                    let lines = verse.value?.replacingOccurrences(of: "\n", with: "<br/>")
                    
                    let verseElement = lyricsElement.addChild(name: "verse", attributes: ["name": verseType + verseLabel])
                    verseElement.addChild(name: "lines", value: lines!.toAscii())
                }
            }
        } catch {
            print("Error parsing the lyrics xml")
        }
        return lyricsElement
    }
    
    func getData(forSong song: Songs) -> [[String: String]] {
        var data: [[String: String]] = []
        
        var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
        var verseOrderList: NSMutableArray = NSMutableArray()
        (listDataDictionary, verseOrderList) = LyricsXmlParser().parse(song: song)
        
        print("Verse order : \(song.verse_order)")
        
        for verseOrderItem in song.verse_order.components(separatedBy: " ") {
            let verseOrderItemString = (verseOrderItem as! String)
            let rawSlide: String? = listDataDictionary[verseOrderItemString.lowercased()] as? String
            
            var dataItem: [String: String] = [:]
            var linesInSlide = rawSlide?.components(separatedBy: "\n")
            var firstLineInSlide: String = linesInSlide?[0] ?? ""
            let title = firstLineInSlide.count > 30 ? String(firstLineInSlide.prefix(30)) : firstLineInSlide
            dataItem["title"] = title.toAscii()
            dataItem["verseTag"] = verseOrderItem.uppercased()
            dataItem["raw_slide"] = rawSlide?.toAscii()
            
            data.append(dataItem)
        }
        
        return data
    }
}
