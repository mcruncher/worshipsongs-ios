//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import SwiftyJSON

protocol IOpenLPServiceConverter {
    func toOszlJson(favouriteList: [FavoritesSongsWithOrder]) -> JSON
}
