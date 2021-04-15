//
// Author: James Selvakumar
// Since: 3.1.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import SwinjectStoryboard
import Swinject
import SwinjectAutoregistration

extension SwinjectStoryboard {
    @objc class func setup() {
        AppLogger.log(level: .debug, "Preparing DI container...")        
        registerServices()
    }
    
    class func registerServices() {
        defaultContainer.autoregister(IOpenLPServiceConverter.self, initializer: OpenLPServiceConverter.init)
        registerViewControllerDependencies()
    }
    
    class func registerViewControllerDependencies() {
        defaultContainer.storyboardInitCompleted(FavoritesTableViewController.self){ resolver, controller in
            controller.openLPServiceConverter = resolver ~> IOpenLPServiceConverter.self
        }
    }
}
