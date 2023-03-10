//
//
// author: Madasamy, Vignesh Palanisamy
// version: 1.7.0
//

import UIKit

class RemoteUrlViewController: UIViewController {

    @IBOutlet weak var remoteUrl: UITextView!
    fileprivate let preferences = NSUbiquitousKeyValueStore.default
    fileprivate let databaseService = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.remoteUrl.layer.cornerRadius = 10
        self.remoteUrl.clipsToBounds = true
        remoteUrl.text = self.preferences.string(forKey: "remote.url")!
        remoteUrl.becomeFirstResponder()
        remoteUrl.isScrollEnabled = true
        self.title = "enterRemoteUrl".localized
        let backButton = UIBarButtonItem(title: "load".localized, style: .plain, target: self, action: #selector(RemoteUrlViewController.doneLoading))
        navigationItem.rightBarButtonItem = backButton
    }
    
    @objc func doneLoading() {
        if !remoteUrl.text!.isEmpty && (remoteUrl.text?.contains(".sqlite") )!{
            self.preferences.set(remoteUrl.text, forKey: "remote.url")
            self.preferences.synchronize()
            databaseService.importDatabase(url: NSURL(string: remoteUrl.text!)! as URL)
            self.navigationController!.popToRootViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "invalid.file".localized, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if DeviceUtils.isIpad() {
            splitViewController?.preferredPrimaryColumnWidthFraction = 1.0
            splitViewController?.maximumPrimaryColumnWidth = (splitViewController?.view.bounds.size.width)!
            let leftNavController = splitViewController?.viewControllers.first as! UINavigationController
            leftNavController.view.frame = CGRect(x: leftNavController.view.frame.origin.x, y: leftNavController.view.frame.origin.y, width: (splitViewController?.view.bounds.size.width)!, height: leftNavController.view.frame.height)
        }
    }
    
}
