//
// author: Madasamy
// version: 1.8.0
//

import UIKit

class StartUpController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            performSegue(withIdentifier: "tabletView", sender: self)
        } else {
            setPhoneRootViewController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func setPhoneRootViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let songsController = mainStoryboard.instantiateViewController(withIdentifier: "phoneView") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = songsController
    }
    
}
