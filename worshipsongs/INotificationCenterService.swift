//
// Author: Vignesh Palanisamy
// Since: 3.2
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation

protocol INotificationCenterService {
    func addObserver(_ observer: Any, forName: String, selector: Selector)
    func post(name: String, userInfo: [AnyHashable : Any]?)
}
