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
    let id = "id"
    let title: String = "title"
    let alternateTitle = "alternate_title"
    let lyrics: String = "lyrics"
    let verseOrder: String = "verse_order"
    let comments = "comments"
    
    func getSongModel() -> [(Songs)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        //54D70B97-F386-4746-9A69-692E339668B8
        print("path : \(path)")
        database?.open()
        var songModel = [Songs]()
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT * FROM songs ORDER BY title", withArgumentsIn: [])
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
            "(select COUNT(*) from authors_songs where author_id = a.id) AS no_songs FROM authors AS a ORDER BY a.display_name", withArgumentsIn: [])
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
    
    func findSongsByTitles(_ argument: [String]) -> [(Songs)] {
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
    
    func findSongs(byTitle title: String) -> [Songs] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")

        database?.open()
        var songs = [Songs]()

        var arguments = [AnyObject]()
        arguments.append("%\(title)%" as AnyObject)

        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where title LIKE ? ORDER BY title", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(resultSet!))
            }
        }
        return songs
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
    
    func findAuthor(bySongId songId: String) -> String {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        let path = commonService.getDocumentDirectoryPath("songs.sqlite")
        database?.open()
        
        var arguments = [AnyObject]()
        arguments.append(songId as AnyObject)
        
        var authorName = " "
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM authors where id IN " +
            "(SELECT author_id FROM authors_songs where song_id = ?) ORDER BY display_name", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                authorName = resultSet!.string(forColumn: "display_name")!
            }
        }
        return authorName
    }

    func findAuthors(bySongId songId: String) -> [String] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()

        var authors = [String]()
        
        var arguments = [AnyObject]()
        arguments.append(songId as AnyObject)

        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM authors where id IN " +
            "(SELECT author_id FROM authors_songs where song_id = ?) ORDER BY display_name", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                authors.append(resultSet!.string(forColumn: "display_name")!)
            }
        }
        return authors
    }
    
    func findCategory() -> [(Category)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()
        var categoryModel = [Category]()
        let resultSet1: FMResultSet? = database!.executeQuery("SELECT t.id, t.name, (select COUNT(*) " +
            "from songs_topics where topic_id = t.id) AS no_songs FROM topics AS t ORDER BY t.name", withArgumentsIn: [])
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
    
    func findTopics(bySongId songId: String) -> [String] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()

        var topics = [String]()
        
        var arguments = [AnyObject]()
        arguments.append(songId as AnyObject)

        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM topics where id IN " +
            "(SELECT topic_id FROM songs_topics where song_id = ?) ORDER BY name", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                topics.append(resultSet!.string(forColumn: "name")!)
            }
        }
        return topics
    }
    
    func getSong(_ resultSet: FMResultSet) -> Songs {
        let song = Songs()
        song.id = resultSet.string(forColumn: self.id)!
        song.title = resultSet.string(forColumn: self.title)!
        song.alternateTitle = resultSet.string(forColumn: self.alternateTitle)!
        song.lyrics = resultSet.string(forColumn: self.lyrics)!
        song.verse_order = resultSet.string(forColumn: self.verseOrder)!
        
        let comment = resultSet.string(forColumn: self.comments)
        song.comment = comment != nil ? comment! : ""
        
        return song
    }
    
    private func getAuthor(_ resultSet: FMResultSet) -> Author {
        let id: String = resultSet.string(forColumn: "id")!
        let firstName: String = resultSet.string(forColumn: "first_name")!
        let lastName: String = resultSet.string(forColumn: "last_name")!
        let displayName: String = resultSet.string(forColumn: "display_name")!
        let displayNameTamil : String = getTamilTitle(displayName)
        let displayNameEnglish: String = getEnglishTitle(displayName)
        let noOfSongs: String = resultSet.string(forColumn: "no_songs")!
        return Author(id: id, firstName: firstName, lastName: lastName, displayName: displayName, displayNameTamil: displayNameTamil, displayNameEnglish: displayNameEnglish, noOfSongs: Int(noOfSongs)!)
    }
    
    private func getCategory(_ resultSet: FMResultSet) -> Category {
        let id: String = resultSet.string(forColumn: "id")!
        let name: String = resultSet.string(forColumn: "name")!
        let nameTamil : String = getTamilTitle(name)
        let nameEnglish: String = getEnglishTitle(name)
        let noOfSongs: String = resultSet.string(forColumn: "no_songs")!
        return Category(id: Int(id)!, name: name, nameTamil: nameTamil, nameEnglish: nameEnglish, noOfSongs: Int(noOfSongs)!)
    }
    
    func getTamilTitle(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        if names.count == 2 {
            return names[1].replacingOccurrences(of: "}", with: " ")
        }
        return name
    }
    
    func getEnglishTitle(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        return names[0]
    }
    
}

