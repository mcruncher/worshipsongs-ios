//
// Author: Vignesh Palanisamy
// Since: YOUR_VERSION
// Copyright © 2023 mCruncher. All rights reserved.
// 

import Foundation

class PreferencesService : IPreferencesService {
    
    fileprivate let preferences = NSUbiquitousKeyValueStore.default
    fileprivate let localPreferences = UserDefaults.standard
    
    
    func set(_ anObject: Any?, forKey aKey: String, local: Bool) {
        if local {
            localPreferences.set(anObject, forKey: aKey)
            localPreferences.synchronize()
        } else {
            preferences.set(anObject, forKey: aKey)
            preferences.synchronize()
        }
    }
    
    func object(forKey aKey: String, local: Bool) -> Any? {
        if isExist(forKey: aKey, local: local) {
            if local {
                return localPreferences.object(forKey: aKey)
            } else {
                return preferences.object(forKey: aKey)
            }
        }
        return nil
    }
    
    func isExist(forKey aKey: String, local: Bool) -> Bool {
        if local {
            return localPreferences.dictionaryRepresentation().keys.contains(aKey)
        } else {
            return preferences.dictionaryRepresentation.keys.contains(aKey)
        }
    }
        
}
