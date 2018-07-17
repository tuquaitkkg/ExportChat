//
//  TOUAndPolicyVC.swift
//  ExportChats
//
//  Created by DatDuong on 2/3/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class TOUAndPolicyVC: UIViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfContent: UITextView!
    var textContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfContent.isEditable = false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tfContent.setContentOffset(CGPoint.zero, animated: false)
        // Remove all padding
        self.tfContent.textContainerInset = .zero
        self.tfContent.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tfContent.text = textContent;
    }

    @IBAction func eventBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
