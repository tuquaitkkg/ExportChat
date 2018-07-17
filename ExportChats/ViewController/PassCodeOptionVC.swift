//
//  PassCodeOptionVC.swift
//  ExportChats
//
//  Created by DatDuong on 1/22/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class PassCodeOptionVC: UIViewController {
    
    open var indexClick = 0
    var isChangePassCode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PassCodeIdf" {
            if let vc = segue.destination as? PassCodeVC {
                if indexClick != 0 {
                   vc.kPasswordDigit = self.indexClick
                   vc.isChangePassCode = self.isChangePassCode
                }
            }
        }
    }
    
    func gotoPasscodeVC() {
        self.performSegue(withIdentifier: "PassCodeIdf", sender: self)
    }
    
    @IBAction func btn4Degits(_ sender: Any) {
        self.indexClick = 4
        self.gotoPasscodeVC()
    }
    
    @IBAction func btn6Degits(_ sender: Any) {
        self.indexClick = 6
        self.gotoPasscodeVC()
    }
    
}
