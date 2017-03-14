//
// author: Madasamy
// version: 1.8.0
//

import UIKit

class TitleViewController: UIViewController {

    fileprivate var databaseHelper = DatabaseHelper()
    fileprivate var filteredSongModel = [Songs]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitles()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let song = filteredSongModel[0]
        NotificationCenter.default.post(name: Notification.Name(rawValue: CommonConstansts.OnSelectSongKey), object: nil,  userInfo: [CommonConstansts.songKey: song])
        let firstIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: firstIndexPath, animated: true, scrollPosition: .top)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTitles() {
      filteredSongModel = databaseHelper.getSongModel()
    }

}

extension TitleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

extension TitleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredSongModel[(indexPath as NSIndexPath).row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = filteredSongModel[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name(rawValue: CommonConstansts.OnSelectSongKey), object: nil,  userInfo: [CommonConstansts.songKey: song])
    }
}
