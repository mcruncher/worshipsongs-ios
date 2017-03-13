//
// author: Madasamy
// version: 1.8.0
//

import UIKit

class SongTabletController: UIViewController {

    @IBOutlet weak var titleTableView: UITableView!
    @IBOutlet weak var verseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationItem()
    }
    
    private func setLeftNavigationItem() {
         self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
