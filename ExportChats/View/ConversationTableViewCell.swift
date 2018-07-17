//
//  ConversationTableViewCell.swift
//  ExportChats
//
//  Created by ToanNT on 1/30/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import SWTableViewCell

class ConversationTableViewCell: SWTableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblHour: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
