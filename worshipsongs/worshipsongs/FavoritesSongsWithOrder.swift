//
// @author Vignesh Palanisamy
// @version 1.6.0
//

import Foundation
import UIKit

class FavoritesSongsWithOrder: NSObject, NSCoding {
    var orderNo: Int
    var songListName: String
    var songId: String
    
    init(orderNo: Int, songId: String, songListName: String) {
        self.orderNo = orderNo
        self.songId = songId
        self.songListName = songListName
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let orderNo = aDecoder.decodeInteger(forKey: "orderNo")
        let songId = aDecoder.decodeObject(forKey: "songId") as! String
        let songListName = aDecoder.decodeObject(forKey: "songListName") as! String
        self.init(orderNo: orderNo, songId: songId, songListName: songListName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(orderNo, forKey: "orderNo")
        aCoder.encode(songId, forKey: "songId")
        aCoder.encode(songListName, forKey: "songListName")
    }
}
