//
// @author: Vignesh palanisamy
// @version: 1.x
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
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT a.id, a.first_name, a.last_name, a.display_name," +
            "(select COUNT(*) from authors_songs where author_id = a.id) AS no_songs FROM authors AS a ORDER BY a.display_name", withArgumentsIn: nil)
        if (resultSet1 != nil)
        {
            while resultSet1!.next() {
                authorModel.append(getAuthor(resultSet1!))
            }
        }
        print("ArtistModel count : \(authorModel.count)")
        return authorModel
    }
    
    func getArtistSongsModel(_ argument: String) -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var arguments = [AnyObject]()
        arguments.append(argument as AnyObject)
        var songModel = [Songs]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN " +
            "(SELECT song_id FROM authors_songs where author_id = ?) ORDER BY title", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songModel.append(getSong(resultSet!))
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
        var arguments = [AnyObject]()
        arguments.append(argument as AnyObject)
        var authorName = " "
        let resultSet2: FMResultSet? = database!.executeQuery("SELECT * FROM authors where id IN " +
            "(SELECT author_id FROM authors_songs where song_id = ?) ORDER BY display_name", withArgumentsIn: arguments)
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
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT t.id, t.name, (select COUNT(*) " +
            "from songs_topics where topic_id = t.id) AS no_songs FROM topics AS t ORDER BY t.name", withArgumentsIn: nil)
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
        var arguments = [AnyObject]()
        arguments.append(categoryId as AnyObject)
        var songModel = [Songs]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN " +
            "(SELECT song_id FROM songs_topics where topic_id = ?) ORDER BY title", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songModel.append(getSong(resultSet!))
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
        let noOfSongs: String = resultSet.string(forColumn: "no_songs")
        return Author(id: id, firstName: firstName, lastName: lastName, displayName: displayName, displayNameTamil: displayNameTamil, displayNameEnglish: displayNameEnglish, noOfSongs: Int(noOfSongs)!)
    }
     
    private func getCategory(_ resultSet: FMResultSet) -> Category {
        let id: String = resultSet.string(forColumn: "id")
        let name: String = resultSet.string(forColumn: "name")
        let nameTamil : String = getTamilTitle(name)
        let nameEnglish: String = getEnglishTitle(name)
        let noOfSongs: String = resultSet.string(forColumn: "no_songs")
        return Category(id: Int(id)!, name: name, nameTamil: nameTamil, nameEnglish: nameEnglish, noOfSongs: Int(noOfSongs)!)
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
