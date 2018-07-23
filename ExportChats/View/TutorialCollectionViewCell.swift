//
//  TutorialCollectionViewCell.swift
//  ExportChats
//
//  Created by Duc.LT on 7/20/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class TutorialCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var clickNext:(()->())?
    @IBOutlet weak var btnNext: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        btnNext.layer.cornerRadius = btnNext.frame.size.height/2
    }
    @IBAction func clickNextButton(_ sender: Any) {
        if self.clickNext != nil {
            self.clickNext!()
        }
    }
}
