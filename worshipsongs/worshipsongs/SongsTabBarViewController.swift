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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func GoToSettingView(_ sender: Any) {
        performSegue(withIdentifier: "setting", sender: self)
    }
}

extension SongsTabBarViewController: UISplitViewControllerDelegate {
   
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}
