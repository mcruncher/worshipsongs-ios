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

protocol SearchDelegateIOS11 {
    func hideSearch()
    func filter(_ searchBar: UISearchBar)
}

protocol SearchDelegateFor4S {
    func reloadSearchData()
    func cancelSearch()
}

class SongsTabBarViewController: UITabBarController{
    
    fileprivate let preferences = UserDefaults.standard
    fileprivate var searchBar: UISearchBar!
    weak var songdelegate: SongSelectionDelegate?
    var searchDelegate: SearchDelegateIOS11?
    var searchDelegate4S: SearchDelegateFor4S?
    var collapseDetailViewController = true
    var secondWindow: UIWindow?
    var presentationData = PresentationData()
    var searchBarDisplay = false
    var optionMenu = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.cruncherBlue()
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.onBeforeUpdateDatabase(_:)), name: NSNotification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.refreshTabbar(_:)), name: NSNotification.Name(rawValue: "refreshTabbar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.activeTabbar(_:)), name:
            NSNotification.Name(rawValue: CommonConstansts.activeTabbar), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SongsTabBarViewController.hideSearchBar), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        initLeftNavBarButton()
        setSearchBar()
        splitViewController?.delegate = self
        self.viewControllers?[0].tabBarItem.title = "songs".localized
        self.viewControllers?[1].tabBarItem.title = "artists".localized
        self.viewControllers?[2].tabBarItem.title = "categories".localized
        self.viewControllers?[3].tabBarItem.title = "song_books".localized
        self.viewControllers?[4].tabBarItem.title = "favorites".localized
    }
    
    @objc func onBeforeUpdateDatabase(_ nsNotification: NSNotification) {
        if isDatabaseLock() {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "loading") as? DatabaseLoadingViewController
            viewController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(viewController!, animated: false, completion: nil)
        }
    }
    
    func initLeftNavBarButton() {
        self.navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "setting"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SongsTabBarViewController.onClickLeftNavBarButton)), animated: true)
    }
    
    func isDatabaseLock() -> Bool {
        return preferences.dictionaryRepresentation().keys.contains("database.lock") && preferences.bool(forKey:"database.lock")
    }
    
    @objc func refreshTabbar(_ nsNotification: NSNotification) {
        self.selectedViewController?.viewWillAppear(true)
        self.viewControllers?[0].tabBarItem.title = "songs".localized
        self.viewControllers?[1].tabBarItem.title = "artists".localized
        self.viewControllers?[2].tabBarItem.title = "categories".localized
        self.viewControllers?[3].tabBarItem.title = "song_books".localized
        self.viewControllers?[4].tabBarItem.title = "favorites".localized
    }
    
    @objc func activeTabbar(_ notification: NSNotification) {
        self.selectedViewController?.viewWillAppear(true)
        self.viewControllers?[0].tabBarItem.title = "songs".localized
        self.viewControllers?[1].tabBarItem.title = "artists".localized
        self.viewControllers?[2].tabBarItem.title = "categories".localized
        self.viewControllers?[3].tabBarItem.title = "song_books".localized
        self.viewControllers?[4].tabBarItem.title = "favorites".localized
        let activeTab = ((notification as NSNotification).userInfo![CommonConstansts.activeTab] as? String)!
        var tabid = 0
        while tabid < (self.viewControllers?.count)! {
            if self.viewControllers?[tabid].tabBarItem.title == activeTab {
                self.selectedIndex = tabid
            }
            tabid = tabid + 1
        }
    }
    
    @objc func hideSearchBar() {
        searchDelegate?.hideSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentationData = PresentationData()
        presentationData.setupScreen()
        if DeviceUtils.isIpad() {
            self.onChangeOrientation(orientation: UIDevice.current.orientation)
        }
    }
    
    func setSearchBar() {
        DispatchQueue.main.async {
            if #available(iOS 11.0, *) {
                let search = UISearchController(searchResultsController: nil)
                search.searchResultsUpdater = self
                self.navigationItem.searchController = search
                self.navigationItem.searchController?.dimsBackgroundDuringPresentation = false
                self.definesPresentationContext = true
            } else {
                self.addSearchBar()
            }
        }
    }
    
    func addSearchBar() {
        // Search bar
        let searchBarFrame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: 44);
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self;
        searchBar.showsCancelButton = true;
        searchBar.tintColor = UIColor.gray
        self.addSearchBarButton()
    }
    
    fileprivate func addSearchBarButton() {
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(SongsTabBarViewController.searchButtonItemClicked(_:))), animated: true)
    }
    
    @objc func searchButtonItemClicked(_ sender:UIBarButtonItem) {
        self.navigationItem.titleView = searchBar;
        searchBarDisplay = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func GoToSettingView(_ sender: Any) {
        if searchBarDisplay {
            optionMenu = UIAlertController(title: nil, message: "searchBy".localized, preferredStyle: .actionSheet)
            optionMenu.addAction(searchByAction("searchByTitle"))
            optionMenu.addAction(searchByAction("searchByContent"))
            optionMenu.addAction(getCancelAction())
            optionMenu.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            onClickLeftNavBarButton()
        }
    }
    
    fileprivate func getCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "cancel".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
    }
    
    func searchByAction(_ option: String) -> UIAlertAction {
        return UIAlertAction(title: option.localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.preferences.set(option, forKey: "searchBy")
            self.preferences.synchronize()
            self.navigationItem.leftBarButtonItem?.image = UIImage(named: option)
        })
    }
    
    @objc func onClickLeftNavBarButton() {
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

extension SongsTabBarViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchDelegate?.filter(searchController.searchBar)
    }
}

extension SongsTabBarViewController: UISearchBarDelegate {
    
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDelegate?.filter(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeSearchBar()
        searchDelegate4S?.reloadSearchData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeSearchBar()
        searchDelegate4S?.cancelSearch()
    }
    
    func closeSearchBar() {
        guard #available(iOS 11.0, *) else {
            self.navigationItem.titleView = nil
            searchBarDisplay = false
            optionMenu.dismiss(animated: true, completion: nil)
            addSearchBarButton()
            self.searchBar.text = ""
            initLeftNavBarButton()
            return
        }
    }
}
