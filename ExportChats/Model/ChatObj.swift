//
//  ChatObj.swift
//  ExportChats
//
//  Created by ToanNT on 1/25/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class ChatObj: NSObject {
    var chatOwner : String!
    var time : Date!
    var text : String!
    var filePath : String?
    
    init(owner: String, timeS: Date, textS: String, filePathS: String) {
        chatOwner = owner
        time = timeS
        text = textS
        filePath = filePathS
    }
}
