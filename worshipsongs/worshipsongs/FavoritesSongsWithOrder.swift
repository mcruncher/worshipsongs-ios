//
// @author Vignesh Palanisamy
// @version 1.6.0
//

import Foundation
import UIKit

class FavoritesSongsWithOrder: NSObject, NSCoding {
    var orderNo: Int
    var songListName: String
    var songName: String
    
    init(orderNo: Int, songName: String, songListName: String) {
        self.orderNo = orderNo
        self.songName = songName
        self.songListName = songListName
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let orderNo = aDecoder.decodeInteger(forKey: "orderNo")
        let songName = aDecoder.decodeObject(forKey: "songName") as! String
        let songListName = aDecoder.decodeObject(forKey: "songListName") as! String
        self.init(orderNo: orderNo, songName: songName, songListName: songListName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(orderNo, forKey: "orderNo")
        aCoder.encode(songName, forKey: "songName")
        aCoder.encode(songListName, forKey: "songListName")
    }
}
