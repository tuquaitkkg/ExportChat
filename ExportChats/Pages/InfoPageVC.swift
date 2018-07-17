//
//  InfoPageVC.swift
//  CallSantaChristmas
//
//  Created by Dat Duong on 12/9/17.
//  Copyright © 2017 Dat Duong. All rights reserved.
//

import UIKit

class InfoPageVC: UIViewController {
    
    @IBOutlet weak var lblContent: UITextView!
    @IBOutlet weak var lblTitle: UILabel!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblContent.isEditable = false
        switch index {
        case 1:
            self.lblTitle.text = "Privacy Policy"
            self.lblContent.text = Constant.Info.infoOfPolicy
            break
        default:
            self.lblTitle.text = "Terms of Use"
            self.lblContent.text = Constant.Info.infoOfTOU
            break
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
