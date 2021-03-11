
//
// author: Mylene Bayan, Vignesh Palanisamy
// version: 2.3.x
// url: https://github.com/mnbayan/AutocompleteTextfieldSwift
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


open class AutoCompleteTextField: UITextField, UITableViewDataSource, UITableViewDelegate {
    /// Manages the instance of tableview
    fileprivate var autoCompleteTableView: UITableView?
    /// Holds the collection of attributed strings
    fileprivate var attributedAutoCompleteStrings: [NSAttributedString]?
    /// Handles user selection action on autocomplete table view
    open var onSelect: (String, IndexPath) -> () = {_,_ in}
    /// Handles textfield's textchanged
    open var onTextChange: (String) -> () = {_ in}
    
    /// Font for the text suggestions
    open var autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12)
    /// Color of the text suggestions
    open var autoCompleteTextColor = UIColor.black
    /// Used to set the height of cell for each suggestions
    open var autoCompleteCellHeight: CGFloat = 44.0
    /// The maximum visible suggestion
    open var maximumAutoCompleteCount = 3
    /// Used to set your own preferred separator inset
    open var autoCompleteSeparatorInset = UIEdgeInsets.zero
    /// Shows autocomplete text with formatting
    open var enableAttributedText = false
    /// User Defined Attributes
    open var autoCompleteAttributes: [NSAttributedStringKey: AnyObject]?
    // Hides autocomplete tableview after selecting a suggestion
    open var hidesWhenSelected = true
    /// Hides autocomplete tableview when the textfield is empty
    open var hidesWhenEmpty: Bool? {
        didSet {
            assert(hidesWhenEmpty != nil, "hideWhenEmpty cannot be set to nil")
            autoCompleteTableView?.isHidden = hidesWhenEmpty!
        }
    }
    /// The table view height
    open var autoCompleteTableHeight: CGFloat? {
        didSet {
            redrawTable()
        }
    }
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    open var autoCompleteStrings: [String]? {
        didSet {
            reload()
        }
    }
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        commonInit()
        setupAutocompleteTable(newSuperview!)
    }
    
    open override func resignFirstResponder() -> Bool {
        self.autoCompleteTableView?.isHidden = true
        
        return super.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteStrings != nil ? (autoCompleteStrings!.count >
            maximumAutoCompleteCount ? maximumAutoCompleteCount : autoCompleteStrings!.count) : 0
        
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if enableAttributedText {
            cell?.textLabel?.attributedText = attributedAutoCompleteStrings![(indexPath as NSIndexPath).row]
        }
        else {
            cell?.textLabel?.font = autoCompleteTextFont
            cell?.textLabel?.textColor = autoCompleteTextColor
            cell?.textLabel?.text = autoCompleteStrings![(indexPath as NSIndexPath).row]
        }
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let selectedText = cell!.textLabel!.text!
        self.text = selectedText
        
        onSelect(selectedText, indexPath)
        
        DispatchQueue.main.async(execute: { () -> Void in
            tableView.isHidden = self.hidesWhenSelected
        })
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = autoCompleteSeparatorInset
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = autoCompleteSeparatorInset
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
    
    // MARK: - Private Interface
    fileprivate func reload() {
        if enableAttributedText {
            let attrs = [NSAttributedStringKey.foregroundColor: autoCompleteTextColor, NSAttributedStringKey.font:
                UIFont.systemFont(ofSize: 12.0)] as [NSAttributedStringKey : Any]
            if attributedAutoCompleteStrings == nil {
                attributedAutoCompleteStrings = [NSAttributedString]()
            } else {
                if attributedAutoCompleteStrings?.count > 0 {
                    attributedAutoCompleteStrings?.removeAll(keepingCapacity: false)
                }
            }
            
            if autoCompleteStrings != nil {
                for i in 0..<autoCompleteStrings!.count {
                    let str = autoCompleteStrings![i] as NSString
                    let range = str.range(of: text!, options: .caseInsensitive)
                    let attString = NSMutableAttributedString(string: autoCompleteStrings![i], attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes!, range: range)
                    attributedAutoCompleteStrings?.append(attString)
                }
            }
        }
        autoCompleteTableView?.reloadData()
    }
    
    fileprivate func commonInit() {
        hidesWhenEmpty = true
        autoCompleteAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        autoCompleteAttributes![NSAttributedStringKey.font] = UIFont(name: "HelveticaNeue-Bold", size: 12)
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), for: .editingChanged)
    }
    
    fileprivate func setupAutocompleteTable(_ view: UIView) {
        let screenSize = UIScreen.main.bounds.size
        let tableView = UITableView(frame: CGRect(x: self.frame.origin.x, y:
            self.frame.origin.y + self.frame.height, width: screenSize.width - (self.frame.origin.x * 2), height: 30.0))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty ?? true
        view.addSubview(tableView)
        autoCompleteTableView = tableView
        autoCompleteTableHeight = 100.0
    }
    
    fileprivate func redrawTable() {
        if autoCompleteTableView != nil {
            var newFrame = autoCompleteTableView!.frame
            newFrame.size.height = autoCompleteTableHeight!
            autoCompleteTableView!.frame = newFrame
        }
    }
    
    // MARK: - Internal
    @objc func textFieldDidChange() {
        onTextChange(text!)
        if text!.isEmpty {
            autoCompleteStrings = nil
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.autoCompleteTableView?.isHidden =  self.hidesWhenEmpty! ? self.text!.isEmpty : false
        })
    }
    
}
