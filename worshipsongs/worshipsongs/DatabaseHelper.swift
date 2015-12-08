//
//  DatabaseHelper.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit


class DatabaseHelper: NSObject {
    
    var database: FMDatabase? = nil
    var resultSet: FMResultSet? = nil
    let commonService: CommonService = CommonService()
   
    func getSongModel() -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var songModel = [Songs]()
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM songs ORDER BY title", withArgumentsInArray: nil)
        let titles: String = "title"
        let lyrics: String = "lyrics"
        let verseOrder: String = "verse_order"
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                songModel.append(Songs(title: resultSet1!.stringForColumn(titles), lyrics: resultSet1!.stringForColumn(lyrics),verse_order: resultSet1!.stringForColumn(verseOrder)))
            }
        }
        print("songModel count : \(songModel.count)")
        return songModel
    }
    
    func getArtistModel() -> [(Author)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var authorModel = [Author]()
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM authors ORDER BY display_name", withArgumentsInArray: nil)
        let id:String = "id"
        let firstName: String = "first_name"
        let lastName: String = "last_name"
        let displayName: String = "display_name"
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                authorModel.append(Author(id: resultSet1!.stringForColumn(id), firstName: resultSet1!.stringForColumn(firstName), lastName: resultSet1!.stringForColumn(lastName), displayName: resultSet1!.stringForColumn(displayName)))
            }
        }
        print("songModel count : \(authorModel.count)")
        return authorModel
    }
    
    func getArtistSongsModel(argument: String) -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var songModelIds = [AnyObject]()
        var arguments = [AnyObject]()
        var args:String = ""
        arguments.append(argument)
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM authors_songs where author_id = ?", withArgumentsInArray: arguments)
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                if(args != "")
                {
                   args="\(args),"
                }
                args="\(args)?"
                songModelIds.append(resultSet1!.stringForColumn("song_id"))
            }
        }
        var songModel = [Songs]()
        let resultSet2: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN (\(args)) ORDER BY title", withArgumentsInArray: songModelIds)
        let titles: String = "title"
        let lyrics: String = "lyrics"
        let verseOrder: String = "verse_order"
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                songModel.append(Songs(title: resultSet2!.stringForColumn(titles), lyrics: resultSet2!.stringForColumn(lyrics),verse_order: resultSet2!.stringForColumn(verseOrder)))
            }
        }
        return songModel
    }
    
}
