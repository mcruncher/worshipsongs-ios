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
         let utilClass:Util = Util()
        sharedInstance.database = FMDatabase(path: utilClass.getPath("songs.sqlite"))
        var path = utilClass.getPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        println("path : \(path)")
        return sharedInstance
    }
    
    func getSongModel() -> [(Songs)] {
        initSetup()
        var songModel = [Songs]()
        var resultSet1: FMResultSet? = sharedInstance.database!.executeQuery("SELECT * FROM songs ORDER BY title", withArgumentsInArray: nil)
        var titles: String = "title"
        var lyrics: String = "lyrics"
        var verseOrder: String = "verse_order"
        var titleList : NSMutableArray = []
        var lyricsList : NSMutableArray = []
        var verseOrderList : NSMutableArray = []
        var songArray : NSMutableArray = []
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                songModel.append(Songs(title: resultSet1!.stringForColumn(titles), lyrics: resultSet1!.stringForColumn(lyrics),verse_order: resultSet1!.stringForColumn(verseOrder)))
            }
        }
        println("songModel count : \(songModel.count)")
        return songModel
    }
    
    func initSetup()
    {
        sharedInstance.database!.open()
    }
    
}
