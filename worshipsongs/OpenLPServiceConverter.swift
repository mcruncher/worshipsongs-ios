//
// Author: James Selvakumar
// Since: 3.0.0
// Ref: https://gitlab.com/openlp/openlp/-/blob/master/openlp/core/lib/serviceitem.py
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import SwiftyJSON
import AEXML
import Zip

class OpenLPServiceConverter : IOpenLPServiceConverter {
    private let databaseHelper = DatabaseHelper()
    private let nonWordCharactersPattern = "[\\W_]+"
    private let apostrophePattern = "[\\'`’ʻ′]"
    
    func toOpenLPServiceLite(favouriteName: String, favouriteList: [FavoritesSong]) -> URL? {
        do {
            let serviceDataFilePath = SimplePDFUtilities.pathForTmpFile("service_data.osj")
            let serviceFilePath = SimplePDFUtilities.pathForTmpFile("\(favouriteName).oszl")
            
            let serviceDataFileUrl = URL(fileURLWithPath: serviceDataFilePath)
            let serviceFileUrl = URL(fileURLWithPath: serviceFilePath)
            
            createServiceDataFile(favouriteList: favouriteList, url: serviceDataFileUrl)
            createServiceFile(favouriteName: favouriteName, serviceDataFileUrl: serviceDataFileUrl, serviceFileUrl: serviceFileUrl)
            return serviceFileUrl
        } catch {
            AppLogger.log(level: .error, "Error occurred while converting the favourite list to OpenLP Service Lite.")
            print(error)
        }
        return nil
    }
    
    private func createServiceDataFile(favouriteList: [FavoritesSong], url: URL) {
        do {
            let json = toOszlJson(favouriteList: favouriteList)
            let jsonRawString = json.rawString(options: .init(rawValue: 0))
            var jsonString = jsonRawString!.replacingOccurrences(of: "\\\\", with: "\\").replacingOccurrences(of: "\\/", with: "/")
            AppLogger.log(level: .debug, "Json string: \n \(jsonString)")
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(atPath: url.path)
            }
            try jsonString.write(to: url, atomically: true, encoding: .ascii)
            AppLogger.log(level: .debug, "Finished writing the json to the file \(url.path)")
        } catch {
            AppLogger.log(level: .error, "Error occurred while creating service data file")
            print(error)
        }
    }
    
    private func createServiceFile(favouriteName: String, serviceDataFileUrl: URL, serviceFileUrl: URL) {
        do {
            if FileManager.default.fileExists(atPath: serviceFileUrl.path) {
                try FileManager.default.removeItem(atPath: serviceFileUrl.path)
            }

            Zip.addCustomFileExtension(serviceFileUrl.pathExtension)
            try Zip.zipFiles(paths: [serviceDataFileUrl], zipFilePath: serviceFileUrl, password: nil, progress: nil)
            AppLogger.log(level: .info, "Finished creating the service file \(serviceFileUrl)")
            
            AppLogger.log(level: .debug, "Removing the service data file \(serviceDataFileUrl)")
            try FileManager.default.removeItem(at: serviceDataFileUrl)
        } catch {
            print("Error occurred while creating service file")
        }
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
            "xml_version": getXmlVersionAsString(forSong: song, withAuthors: authors),
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
    
    func getHeaderData(forSong song: Songs, forAuthors authors: [String]) -> [String : String] {
        let data = [
            "title": "\(getSearchString(song.title))@\(getSearchString(song.alternateTitle))",
            "authors": authors.joined(separator: ", ")
        ]
        return data
    }
    
    // Ref: https://gitlab.com/openlp/openlp/-/blob/2.4.6/openlp/plugins/songs/lib/__init__.py#L342
    func getSearchString(_ string: String) -> String {
        return string.replacingOccurrences(of: apostrophePattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: nonWordCharactersPattern, with: " ", options: .regularExpression)
            .lowercased()
    }
    
    func getXmlVersionAsString(forSong song: Songs, withAuthors authors: [String]) -> String {
        var xmlString = getXmlVersion(forSong: song, withAuthors: authors).xmlCompact
        xmlString = xmlString.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "&apos;", with: "'")
        return xmlString
    }
    
    func getXmlVersion(forSong song: Songs, withAuthors authors: [String]) -> AEXMLDocument {
        let root = WSXMLDocument()
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
            AppLogger.log(level: .error, "Error parsing the lyrics xml")
            print(error)
        }
        return lyricsElement
    }
    
    func getData(forSong song: Songs) -> [[String: String]] {
        var data: [[String: String]] = []
        
        var listDataDictionary : NSMutableDictionary = NSMutableDictionary()
        var verseOrderList: NSMutableArray = NSMutableArray()
        (listDataDictionary, verseOrderList) = LyricsXmlParser().parse(song: song)
        
        AppLogger.log(level: .debug, "Verse order : \(song.verse_order)")
        
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

class WSXMLDocument : AEXMLDocument {
    open override var xml: String {
        var xml =  "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        xml += root.xml
        return xml
    }
}
