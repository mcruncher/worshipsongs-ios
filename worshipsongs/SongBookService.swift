//
// author: Madasamy
// version: 2.3.0
//
import UIKit
import FMDB

class SongBookService: NSObject {
    
    private var database: FMDatabase? = nil
    private  let commonService: CommonService = CommonService()
    private let databaseService = DatabaseHelper()
    private let id = "id"
    private let name = "name"
    private let publisher = "publisher"
    private let entry = "entry"
    private let noOfSongs = "no_of_songs"
    
    func findAll() -> [SongBook]  {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()
        var songBooks = [SongBook]()
        let resultSet: FMResultSet? = database!.executeQuery("select sb.id, sb.name, sb.publisher, " +
            "(select count(*) from songs_songbooks where songbook_id = sb.id) as no_of_songs " +
            "from song_books as sb order by sb.name ", withArgumentsIn: [])
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songBooks.append(getSongBook(resultSet!))
            }
        }
        return songBooks
    }
    
    private func getSongBook(_ resultSet: FMResultSet) -> SongBook {
        let id: String = resultSet.string(forColumn: self.id)!
        let tamilName = databaseService.getTamilTitle(resultSet.string(forColumn: name)!)
        let englishName = databaseService.getEnglishTitle(resultSet.string(forColumn: name)!)
        let publisher: String = resultSet.string(forColumn: self.publisher) != nil ? resultSet.string(forColumn: self.publisher)! : ""
        let noOfSongs: String = resultSet.string(forColumn: self.noOfSongs)!
        return SongBook(id: Int(id)!, tamilName: tamilName, englishName: englishName, publisher: publisher, noOfSongs: Int(noOfSongs)!)
    }
    
    func findBySongBookId(_ songBookId: Int) -> [Songs] {
        var songList = [Songs]()
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()
        var arguments = [AnyObject]()
        arguments.append(songBookId as AnyObject)
        let resultSet: FMResultSet? = database!.executeQuery("select * from songs as s inner join songs_songbooks as ssb on ssb.song_id = s.id inner join song_books as sb on ssb.songbook_id = sb.id where sb.id = ?", withArgumentsIn: arguments)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                let song = databaseService.getSong(fromResultSet: resultSet!)
                song.songBookNo = (resultSet?.string(forColumn: entry))!
                songList.append(song)
            }
        }
        return songList
    }
    
}

