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
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                songModel.append(getSong(resultSet1!))
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
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                authorModel.append(getAuthor(resultSet1!))
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
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                
                songModel.append(getSong(resultSet2!))
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
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                songModel.append(getSong(resultSet2!))
            }
        }
        print("songModel count : \(songModel.count)")
        return songModel
    }
    
    func getSongsModelByIds(_ argument: [String]) -> [(Songs)] {
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
        let resultSet2: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN (\(args)) ORDER BY title", withArgumentsIn: argument)
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                songModel.append(getSong(resultSet2!))
            }
        }
        print("songModel count : \(songModel.count)")
        return songModel
    }
    
    func getArtistName(_ argument: String) -> String {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var songModelIds = [AnyObject]()
        var arguments = [AnyObject]()
        var args:String = ""
        arguments.append(argument as AnyObject)
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM authors_songs where song_id = ?", withArgumentsIn: arguments)
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                if(args != "")
                {
                    args="\(args),"
                }
                args="\(args)?"
                songModelIds.append(resultSet1!.string(forColumn: "author_id") as AnyObject)
            }
        }
        var authorName = " "
        let resultSet2: FMResultSet? = database!.executeQuery("SELECT * FROM authors where id IN (\(args)) ORDER BY display_name", withArgumentsIn: songModelIds)
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                authorName = resultSet2!.string(forColumn: "display_name")
            }
        }
        return authorName
    }
    
    func findCategory() -> [(Category)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()
        var categoryModel = [Category]()
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM topics ORDER BY name", withArgumentsIn: nil)
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                categoryModel.append(getCategory(resultSet1!))
            }
        }
        print("Categories: \(categoryModel.count)")
        return categoryModel
    }
    
    func findCategorySongs(_ categoryId: Int) -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()
        var songModelIds = [AnyObject]()
        var arguments = [AnyObject]()
        var args:String = ""
        arguments.append(categoryId as AnyObject)
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM songs_topics where topic_id = ?", withArgumentsIn: arguments)
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
        let id = "id"
        let titles: String = "title"
        let lyrics: String = "lyrics"
        let verseOrder: String = "verse_order"
        if (resultSet2 != nil)
        {
            while resultSet2!.next() {
                songModel.append(Songs(id: resultSet2!.string(forColumn: id), title: resultSet2!.string(forColumn: titles), lyrics: resultSet2!.string(forColumn: lyrics),verse_order: resultSet2!.string(forColumn: verseOrder), comment: resultSet2!.string(forColumn: "comments")))
            }
        }
        return songModel
    }
    
    private func getSong(_ resultSet: FMResultSet) -> Songs {
        let id : String = resultSet.string(forColumn: "id")
        let title: String = resultSet.string(forColumn: "title")
        let lyrics: String = resultSet.string(forColumn: "lyrics")
        let verseOrder: String = resultSet.string(forColumn: "verse_order")
        let comments: String = resultSet.string(forColumn: "comments") != nil ? resultSet.string(forColumn: "comments") : ""
        return Songs(id: id, title: title, lyrics: lyrics, verse_order: verseOrder, comment: comments)
    }
    
    private func getAuthor(_ resultSet: FMResultSet) -> Author {
        let id: String = resultSet.string(forColumn: "id")
        let firstName: String = resultSet.string(forColumn: "first_name")
        let lastName: String = resultSet.string(forColumn: "last_name")
        let displayName: String = resultSet.string(forColumn: "display_name")
        let displayNameTamil : String = getTamilTitle(displayName)
        let displayNameEnglish: String = getEnglishTitle(displayName)
        return Author(id: id, firstName: firstName, lastName: lastName, displayName: displayName, displayNameTamil: displayNameTamil, displayNameEnglish: displayNameEnglish)
    }
     
    private func getCategory(_ resultSet: FMResultSet) -> Category {
        let id: String = resultSet.string(forColumn: "id")
        let name: String = resultSet.string(forColumn: "name")
        let nameTamil : String = getTamilTitle(name)
        let nameEnglish: String = getEnglishTitle(name)
        return Category(id: Int(id)!, name: name, nameTamil: nameTamil, nameEnglish: nameEnglish)
    }
    
    private func getTamilTitle(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        if names.count == 2 {
            return names[1].replacingOccurrences(of: "}", with: " ")
        }
        return name
    }
    
    private func getEnglishTitle(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        return names[0]
    }
    
}
