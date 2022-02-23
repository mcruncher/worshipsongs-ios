//
// Author: James Selvakumar
// Credits: Hardy_Germany (https://stackoverflow.com/a/47892340/361172)
// Since: 4.4.0
// Copyright © 2022 mCruncher. All rights reserved.
// 

import Foundation

class MainSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    var collapseDetailView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // if this is an iPad, show both scenes (selection and detail) side by side
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            
            // we have an iPad, so set the mode
            self.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
            
            // we do not want to collapse the detail view on launch
            collapseDetailView = false
            
        } else {
            // we have an iPhone, set the mode
            self.preferredDisplayMode = UISplitViewControllerDisplayMode.automatic
            
            // make sure we collapse the detail view on launch
            collapseDetailView = true
        }
    }
    
    // MARK: - Delegate methods
    // used to collapse the detail view
    // BTW: this method will not be called if preferredDisplayMode == UISplitViewControllerDisplayMode.allVisible
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {        
        // true: detail view will collapse, false: detail View will not collapse
        return collapseDetailView
    }
}
