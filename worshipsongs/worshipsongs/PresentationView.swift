//
//  PresentationView.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 02/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class PresentationView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var slideNumberLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    fileprivate let preferences = UserDefaults.standard
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiateNib()
    }
    
    func instantiateNib() {
        UINib(nibName: "PresentationView", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.frame
        let fontSize = self.preferences.integer(forKey: "presentationFontSize")
        songLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        slideNumberLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize) / 3)
        songNameLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize) / 3)
        authorLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize) / 3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiateNib()
    }
        
}
