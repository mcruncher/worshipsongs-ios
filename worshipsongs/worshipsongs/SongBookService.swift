//
// author: Madasamy
// version: 2.3.0
//
import UIKit
import FMDB

class SongBookService: NSObject {
    
    private var database: FMDatabase? = nil
    private  let commonService: CommonService = CommonService()
    private let preferences = UserDefaults.standard
    
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
        print("Song book: \(songBooks.count)")
        return songBooks
    }
    
    private func getSongBook(_ resultSet: FMResultSet) -> SongBook {
        let id: String = resultSet.string(forColumn: "id")
        let name: String =  getName( resultSet.string(forColumn: "name"), "tamil".equalsIgnoreCase(self.preferences.string(forKey: "language")!))
        let publisher: String = resultSet.string(forColumn: "publisher")
        return SongBook(id:  Int(id)!, name: name, publisher: publisher)
    }
    
    func getName(_ name: String, _ tamil: Bool) -> String {
        if tamil {
            return getTamilName(name)
        } else {
            return getDefaultName(name)
        }
    }
    
     func getTamilName(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        if names.count == 2 {
            return names[1].replacingOccurrences(of: "}", with: "")
        }
        return name
    }
    
     func getDefaultName(_ name: String) -> String {
        let names = name.components(separatedBy: "{")
        return names[0]
    }
    
}
