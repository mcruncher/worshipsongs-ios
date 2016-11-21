//
//  DatabaseHelper.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 10/9/15.
//  Copyright © 2015 Vignesh Palanisamy. All rights reserved.
//

import UIKit
import FMDB


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
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM songs ORDER BY title", withArgumentsIn: nil)
        let titles: String = "title"
        let lyrics: String = "lyrics"
        let verseOrder: String = "verse_order"
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                songModel.append(Songs(title: resultSet1!.string(forColumn: titles), lyrics: resultSet1!.string(forColumn: lyrics),verse_order: resultSet1!.string(forColumn: verseOrder)))
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
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM authors ORDER BY display_name", withArgumentsIn: nil)
        let id:String = "id"
        let firstName: String = "first_name"
        let lastName: String = "last_name"
        let displayName: String = "display_name"
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                authorModel.append(Author(id: resultSet1!.string(forColumn: id), firstName: resultSet1!.string(forColumn: firstName), lastName: resultSet1!.string(forColumn: lastName), displayName: resultSet1!.string(forColumn: displayName)))
            }
        }
        print("songModel count : \(authorModel.count)")
        return authorModel
    }
    
    func getArtistSongsModel(_ argument: String) -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var songModelIds = [AnyObject]()
        var arguments = [AnyObject]()
        var args:String = ""
        arguments.append(argument as AnyObject)
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM authors_songs where author_id = ?", withArgumentsIn: arguments)
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                if(args != "")
                {
                   args="\(args),"
                }
                args="\(args)?"
                songModelIds.append(resultSet1!.string(forColumn: "song_id") as AnyObject)
            }
        }
        var songModel = [Songs]()
        let resultSet2: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN (\(args)) ORDER BY title", withArgumentsIn: songModelIds)
        let titles: String = "title"
        let lyrics: String = "lyrics"
        let verseOrder: String = "verse_order"
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                songModel.append(Songs(title: resultSet2!.string(forColumn: titles), lyrics: resultSet2!.string(forColumn: lyrics),verse_order: resultSet2!.string(forColumn: verseOrder)))
            }
        }
        return songModel
    }
    
    func getSongsModelTitles(_ argument: [String]) -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var songModel = [Songs]()
        
        var args: String = ""
        for _ in argument {
            if(args != "")
            {
                args="\(args),"
            }
            args="\(args)?"
        }
        let resultSet2: FMResultSet? = database!.executeQuery("SELECT * FROM songs where title IN (\(args)) ORDER BY title", withArgumentsIn: argument)
        let titles: String = "title"
        let lyrics: String = "lyrics"
        let verseOrder: String = "verse_order"
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                songModel.append(Songs(title: resultSet2!.string(forColumn: titles), lyrics: resultSet2!.string(forColumn: lyrics),verse_order: resultSet2!.string(forColumn: verseOrder)))
            }
        }
        print("songModel count : \(songModel.count)")
        return songModel
    }
    
}
