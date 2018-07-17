//
//  PageChildrent.swift
//  CallSantaChristmas
//
//  Created by Dat Duong on 12/9/17.
//  Copyright © 2017 Dat Duong. All rights reserved.
//

import UIKit

class PageChildrentVC: UIViewController {

    @IBOutlet weak var lbTest: UILabel!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var viewPurchase: UIView!
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let index = self.index {
            imgBg.image = UIImage(named: "mh\(index)")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
