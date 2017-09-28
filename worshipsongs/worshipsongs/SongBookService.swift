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
    
    func findAll() -> [SongBook]  {
        database = FMDatabase(path: commonService.getDocumentDirectoryPath("songs.sqlite"))
        database?.open()
        var songBooks = [SongBook]()
        let resultSet: FMResultSet? = database!.executeQuery("select * from song_books order by name ", withArgumentsIn: nil)
        if (resultSet != nil)
        {
            while resultSet!.next() {
                songBooks.append(getSongBook(resultSet!))
            }
        }
        return songBooks
    }
    
    private func getSongBook(_ resultSet: FMResultSet) -> SongBook {
        let id: String = resultSet.string(forColumn: self.id)
        let tamilName = getTamilName(resultSet.string(forColumn: name))
        let englishName = getEnglishName(resultSet.string(forColumn: name))
        let publisher: String = resultSet.string(forColumn: self.publisher)
        return SongBook(id:  Int(id)!, tamilName: tamilName, englishName: englishName, publisher: publisher)
    }
    
    func getTamilName(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        if names.count == 2 {
            return names[1].replacingOccurrences(of: "}", with: "")
        }
        return name
    }
    
    func getEnglishName(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        return names[0]
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
                let song = databaseService.getSong(resultSet!)
                song.songBookNo = (resultSet?.string(forColumn: "entry"))!
                songList.append(song)
            }
        }
        return songList
    }
    
}
