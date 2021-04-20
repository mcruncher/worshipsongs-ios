//
// @author: Vignesh palanisamy
// @version: 1.x
//

import UIKit
import FMDB


class DatabaseHelper: NSObject {
    let dbName = "songs.sqlite"
    private let idColumn = "id"
    private let titleColumn: String = "title"
    private let alternateTitleColumn = "alternate_title"
    private let lyricsColumn: String = "lyrics"
    private let verseOrderColumn: String = "verse_order"
    private let lastModifiedColumn = "last_modified"
    private let commentsColumn = "comments"

    var database: FMDatabase? = nil
    let commonService: CommonService = CommonService()
        
    func findSongs() -> [(Song)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var songs = [Song]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs ORDER BY title", withArgumentsIn: [])
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(fromResultSet: resultSet!))
            }
        }
        AppLogger.log(level: .debug, "Total no. of songs: \(songs.count)")
        return songs
    }
        
    func findSongs(byAuthorId authorId: String) -> [(Song)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var arguments = [AnyObject]()
        arguments.append(authorId as AnyObject)
        var songs = [Song]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN " +
            "(SELECT song_id FROM authors_songs where author_id = ?) ORDER BY title", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(fromResultSet: resultSet!))
            }
        }
        return songs
    }
    
    func findSongs(byTitle title: String) -> [Song] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))

        database?.open()
        var songs = [Song]()

        var arguments = [AnyObject]()
        arguments.append("%\(title)%" as AnyObject)

        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where title LIKE ? ORDER BY title", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(fromResultSet: resultSet!))
            }
        }
        return songs
    }
    
    func findSongs(byTitles titles: [String]) -> [(Song)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var songs = [Song]()
        
        var args: String = ""
        for _ in titles {
            if(args != "")
            {
                args="\(args),"
            }
            args="\(args)?"
        }
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where title IN (\(args)) ORDER BY title", withArgumentsIn: titles)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(fromResultSet: resultSet!))
            }
        }
        AppLogger.log(level: .debug, "No. of songs matching the titles \(titles): \(songs.count)")
        return songs
    }

    func findSongs(byCategoryId categoryId: Int) -> [(Song)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var arguments = [AnyObject]()
        arguments.append(categoryId as AnyObject)
        var songs = [Song]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN " +
            "(SELECT song_id FROM songs_topics where topic_id = ?) ORDER BY title", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(fromResultSet: resultSet!))
            }
        }
        return songs
    }
        
    func findSongs(bySongIds ids: [String]) -> [(Song)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var songs = [Song]()
        
        var args: String = ""
        for _ in ids {
            if(args != "")
            {
                args="\(args),"
            }
            args="\(args)?"
        }
        let resultSet: FMResultSet? = database!.executeQuery("SELECT * FROM songs where id IN (\(args)) ORDER BY title", withArgumentsIn: ids)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songs.append(getSong(fromResultSet: resultSet!))
            }
        }
        AppLogger.log(level: .debug, "No. of songs matching the ids \(ids): \(songs.count)")
        return songs
    }
        
    func findAuthors() -> [(Author)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var authors = [Author]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT a.id, a.first_name, a.last_name, a.display_name," +
            "(select COUNT(*) from authors_songs where author_id = a.id) AS no_songs FROM authors AS a ORDER BY a.display_name", withArgumentsIn: [])
        if (resultSet != nil)
        {
            while resultSet!.next() {
                authors.append(getAuthor(resultSet!))
            }
        }
        AppLogger.log(level: .debug, "Total no. of authors: \(authors.count)")
        return authors
    }

    func findAuthor(bySongId songId: String) -> String {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
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
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
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
    
    func findCategories() -> [(Category)] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
        database?.open()
        var categories = [Category]()
        let resultSet: FMResultSet? = database!.executeQuery("SELECT t.id, t.name, (select COUNT(*) " +
            "from songs_topics where topic_id = t.id) AS no_songs FROM topics AS t ORDER BY t.name", withArgumentsIn: [])
        if (resultSet != nil)
        {
            while resultSet!.next() {
                categories.append(getCategory(resultSet!))
            }
        }
        AppLogger.log(level: .debug, "No. of categories: \(categories.count)")
        return categories
    }
        
    func findCategories(bySongId songId: String) -> [String] {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath(dbName))
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
        
    func getSong(fromResultSet resultSet: FMResultSet) -> Song {
        let id = resultSet.string(forColumn: idColumn)!
        let title = resultSet.string(forColumn: titleColumn)!
        let alternateTitle = resultSet.string(forColumn: alternateTitleColumn)!
        let lyrics = resultSet.string(forColumn: lyricsColumn)!
        let verse_order = resultSet.string(forColumn: verseOrderColumn)!
        
        let timestamp = resultSet.string(forColumn: lastModifiedColumn)
        var lastModified: Date?
        
        if timestamp != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            lastModified = dateFormatter.date(from: timestamp!)
        }
        
        var comments = resultSet.string(forColumn: commentsColumn)
        if comments == nil {
            comments = ""
        }
        
        let song = Song(id: id, title: title, lyrics: lyrics, verse_order: verse_order, comment: comments!)
        song.alternateTitle = alternateTitle
        song.lastModified = lastModified
        return song;
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

