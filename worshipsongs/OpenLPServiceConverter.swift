//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import SwiftyJSON

class OpenLPServiceConverter : IOpenLPServiceConverter {
    func toOszlJson(favouriteList: [FavoritesSongsWithOrder]) -> JSON {
        let serviceItemHeaderContent  = [
            "name": "songs",
            "plugin": "songs"
        ] as [String: Any?]
        
        let serviceItemHeader = [
            "header": serviceItemHeaderContent
        ] as [String: Any?]
        
        let serviceItem = ["serviceItem": serviceItemHeader] as [String: Any?]
        
        let openLPService = [getGeneralServiceInfo(), serviceItem, serviceItem]
        
        return JSON(openLPService)
    }
    
    private func getGeneralServiceInfo() -> [String: Any?] {
        let openLPCoreInfo = ["lite_service": true, "service_theme": ""] as [String: Any?]
        let generalServiceInfo = ["openlp_core": openLPCoreInfo] as [String: Any?]
        return generalServiceInfo
    }
}
