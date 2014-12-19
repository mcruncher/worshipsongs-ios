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
        initSongsResultSet()
        var resultSet1: FMResultSet? = sharedInstance.database!.executeQuery("SELECT * FROM songs", withArgumentsInArray: nil)
        //let (result, error) =
        var titles: String = "title"
        var arrayOfArray : NSMutableArray = []
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                arrayOfArray.addObject(resultSet1!.stringForColumn(titles))
            }
        }
        return arrayOfArray
    }
    
    func initSongsResultSet()
    {
        sharedInstance.database!.open()
        resultSet = sharedInstance.database!.executeQuery("SELECT * FROM songs", withArgumentsInArray: nil)
    }
    
}
