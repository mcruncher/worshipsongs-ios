//
// Author: Vignesh (Adapted from the Furiend project)
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import OSLog

struct AppLogger {
    
    static func log(level: LogLevel, _ message: String) {
        if #available(iOS 14.0, *) {
            let logger = Logger()
            switch level {
            case .info:
                logger.info("\(message)")
            case .debug:
                logger.debug("\(message)")
            case .error:
                logger.error("\(message)")
            case .fault:
                logger.fault("\(message)")
            }
        } else {
            print(level.rawValue + ": " + message)
        }
    }
}

enum LogLevel : String {
    case info = "Info"
    case debug = "Debug"
    case error = "Error"
    case fault = "Fault"
}
