//
//  DatabaseHelper.swift
//  worshipsongs
//
//  Created by Seenivasan Sankaran on 12/19/14.
//  Copyright (c) 2014 Seenivasan Sankaran. All rights reserved.
//

import UIKit

let sharedInstance = DatabaseHelper()

class DatabaseHelper: NSObject {
    
    var database: FMDatabase? = nil
    var resultSet: FMResultSet? = nil

    class var instance: DatabaseHelper {
        sharedInstance.database = FMDatabase(path: Util.getPath("songs.sqlite"))
        var path = Util.getPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        println("path : \(path)")
        return sharedInstance
    }
    
    func getTitles() -> NSMutableArray {
        initSetup()
        var resultSet1: FMResultSet? = sharedInstance.database!.executeQuery("SELECT title FROM songs", withArgumentsInArray: nil)
        //let (result, error) =
        var titles: String = "title"
        var titleList : NSMutableArray = []
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                titleList.addObject(resultSet1!.stringForColumn(titles))
            }
        }
        return titleList
    }
    
    func getLyrics(title : String) -> String {
//        let querySQL = "SELECT address, phone FROM CONTACTS WHERE name = '\(name.text)'"
//        
//        let results:FMResultSet? = contactDB.executeQuery(querySQL,
//            withArgumentsInArray: nil)
        
        initSetup()
        var searchLyricsQuery = "SELECT lyrics FROM songs where title = '\(title)'"
        var resultSet1: FMResultSet? = sharedInstance.database!.executeQuery(searchLyricsQuery, withArgumentsInArray: nil)
        //let (result, error) =
        var lyrics: String = "lyrics"
        var titleList : String = ""
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                //titleList.addObject(resultSet1!.stringForColumn(lyrics))
                titleList = resultSet1!.stringForColumn(lyrics)
            }
        }
        return titleList
    }
    
    func initSetup()
    {
        sharedInstance.database!.open()
    }
    
}
