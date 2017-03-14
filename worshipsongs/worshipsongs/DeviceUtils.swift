//
// author: Madasamy
// version: 1.8.0
//

import Foundation
import UIKit

struct DeviceUtils {
   
    static func isIpad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }
}
