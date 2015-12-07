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
    
}
