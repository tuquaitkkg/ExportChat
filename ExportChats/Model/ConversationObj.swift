//
//  ConversationObj.swift
//  ExportChats
//
//  Created by ToanNT on 1/25/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class ConversationObj: NSObject {
    var personName : String!
    var path : String!
    var chats : [ChatObj]?
    
    init(person : String, path : String, chats: [ChatObj]) {
        personName = person
        self.path = path
        self.chats = chats
    }
    
}
