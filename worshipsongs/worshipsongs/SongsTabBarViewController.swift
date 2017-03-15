//
//  SongsTabBarViewController.swift
//  worshipsongs
//
// author: Madasamy, Vignesh Palanisamy
// version: 1.0.0
//

import UIKit


protocol SongSelectionDelegate: class {
    func songSelected(_ song: Songs!)
}

class SongsTabBarViewController: UITabBarController{
    
    fileprivate let preferences = UserDefaults.standard
    weak var songdelegate: SongSelectionDelegate?
    var collapseDetailViewController = true
    var secondWindow: UIWindow?
    var presentationData = PresentationData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.onBeforeUpdateDatabase(_:)), name: NSNotification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.onAfterUpdateDatabase(_:)), name: NSNotification.Name(rawValue: "onAfterUpdateDatabase"), object: nil)
        splitViewController?.delegate = self
    }
    
    func onBeforeUpdateDatabase(_ nsNotification: NSNotification) {
        if isDatabaseLock() {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "loading") as? DatabaseLoadingViewController
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
    }
    
    func isDatabaseLock() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("database.lock") && preferences.bool(forKey:"database.lock")
    }
    
    func onAfterUpdateDatabase(_ nsNotification: NSNotification) {
        self.selectedViewController?.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentationData = PresentationData()
        presentationData.setupScreen()
        if DeviceUtils.isIpad() {
            self.onChangeOrientation(orientation: UIDevice.current.orientation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func GoToSettingView(_ sender: Any) {
        performSegue(withIdentifier: "setting", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard DeviceUtils.isIpad() else {
            return
        }
        guard segue.identifier == "setting" else {
            return
        }
        splitViewController?.preferredPrimaryColumnWidthFraction = 1.0
        splitViewController?.maximumPrimaryColumnWidth = (splitViewController?.view.bounds.size.width)!

    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //setMasterViewWidth()
         self.onChangeOrientation(orientation: UIDevice.current.orientation)
    }
    
    func onChangeOrientation(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeRight, .landscapeLeft :
            setMasterViewWidth(2)
            break
        default:
            setMasterViewWidth(2.50)
            break
        }
    }
    
    fileprivate func setMasterViewWidth(_ widthFraction: CGFloat) {
        if DeviceUtils.isIpad() {
            splitViewController?.preferredPrimaryColumnWidthFraction = 0.40
            let minimumWidth = min((splitViewController?.view.bounds.size.width)!,(splitViewController?.view.bounds.height)!)
            splitViewController?.minimumPrimaryColumnWidth = minimumWidth / widthFraction
            splitViewController?.maximumPrimaryColumnWidth = minimumWidth / widthFraction
            let leftNavController = splitViewController?.viewControllers.first as! UINavigationController
            leftNavController.view.frame = CGRect(x: leftNavController.view.frame.origin.x, y: leftNavController.view.frame.origin.y, width: (minimumWidth / widthFraction), height: leftNavController.view.frame.height)
        }
    }
    
}

extension SongsTabBarViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}
