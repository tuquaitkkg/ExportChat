//
//  UserModel.swift
//  ExportChats
//
//  Created by Dat Duong on 2/1/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    let namePath: String!
    let urlPath: String!

    init(namePath: String, urlPath: String) {
        self.namePath = namePath;
        self.urlPath = urlPath;
    }
}
