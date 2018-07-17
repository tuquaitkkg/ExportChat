//
//  StartVC.swift
//  ExportChats
//
//  Created by DatDuong on 1/22/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import SwiftyStoreKit

class StartVC: UIViewController {
    
    var player = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PassCodeVC") as? PassCodeVC
        let key4Degits = UserDefaults.standard.value(forKey: Constant.udKey.key_passcode_4degit) as? String
        let key6Degits = UserDefaults.standard.value(forKey: Constant.udKey.key_passcode_6degit) as? String
        if key4Degits != nil || key6Degits != nil {
            if key4Degits != nil {
                vc?.kPasswordDigit = 4
            } else if key6Degits != nil {
                vc?.kPasswordDigit = 6
            } else {
                self.gotoPasscodeOptionVC()
                return
            }
        } else {
            self.gotoPasscodeOptionVC()
            return
        }
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    func gotoPasscodeOptionVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PassCodeOptionVC")
        self.navigationController?.pushViewController(vc!, animated: false)
    }
    
    open func getDayFromDate(_ date: Date) -> Int {
        let now = Date()
        let ageComponents: DateComponents? = Calendar.current.dateComponents(Set<Calendar.Component>([.day]), from: date, to: now)
        let age: Int? = ageComponents?.day
        return age ?? 0
    }
}
