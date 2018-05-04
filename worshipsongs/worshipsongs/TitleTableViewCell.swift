//
//  TitleTableViewCell.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 03/01/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var songNumber: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    var titleTextColor = UIColor.black

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
