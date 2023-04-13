//
// Author: Vignesh Palanisamy
// Since: YOUR_VERSION
// Copyright © 2023 mCruncher. All rights reserved.
// 

import Foundation

protocol IPreferencesService {
    func set(_ anObject: Any?, forKey aKey: String, local: Bool)
    func object(forKey aKey: String, local: Bool) -> Any?
    func isExist(forKey aKey: String, local: Bool) -> Bool
}
