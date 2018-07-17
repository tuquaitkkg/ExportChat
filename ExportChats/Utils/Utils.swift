//
//  Utils.swift
//  ExportChats
//
//  Created by DatDuong on 2/3/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class Utils {

    static func getIdGoogle() -> String{
        let idUD = UserDefaults.standard.value(forKey: Constant.udKey.key_user_id_google) as? String
        if let id = idUD {
            return id
        } else {
            return ""
        }
    }
}
