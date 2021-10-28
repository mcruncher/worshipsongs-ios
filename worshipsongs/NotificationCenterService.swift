//
// Author: Vignesh Palanisamy
// Since: 3.2
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation

class NotificationCenterService : INotificationCenterService {
    
    func post(name: String, userInfo: [AnyHashable : Any]?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: userInfo)
    }
    
    func addObserver(_ observer: Any, forName name: String, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
        
}
