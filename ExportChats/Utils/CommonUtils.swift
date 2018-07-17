
//
//  CommonUtils.swift
//  ExportChats
//
//  Created by ToanNT on 1/25/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class CommonUtils: NSObject {
    func conversationWithArrayChat(_ arr: [String], andPathFile path: String) -> ConversationObj {
        var listChat = [ChatObj]()
        for sentence in arr {
            let item = convertTextSentenceToObj(sentenceString: sentence, hostPath: path)
            if item != nil{
                listChat.append(item!)
            }
        }
        let name = listChat.first?.chatOwner
        listChat.removeFirst()
        return ConversationObj(person: name!, path: path, chats: listChat)
    }
    
    func convertTextSentenceToObj(sentenceString : String, hostPath : String) -> ChatObj? {
        if sentenceString == "" {return nil}
        
        let inputStr = sentenceString as NSString
        var isAttached = false
        if inputStr.contains("<‎attached>") {
            isAttached = true
        }
        var divideArr = inputStr.components(separatedBy: "]")
        var dateStr = divideArr[0] as NSString
        divideArr.remove(at: 0)
        let content = arrayStringToString(arr: divideArr)
        print(content)
        var divideContent = content.components(separatedBy: ":")
        let name = divideContent[0].trimmingCharacters(in: .whitespaces)
        print("name:\(name)")
        divideContent.remove(at: 0)
        var text = ""
        var path = hostPath
        if isAttached == true {
            let fileName = arrayStringToString(arr: divideContent)
            let fileStr = fileName.replacingOccurrences(of: " <‎attached>", with: "") as NSString
            let truePath = fileStr.substring(from: 1)
            path = path.appending("/\(truePath)")
            print("Path file is:\(path)")
        } else {
            text = arrayStringToString(arr: divideContent)
            path = ""
        }
        
        dateStr = dateStr.replacingOccurrences(of: "[", with: "") as NSString
        let date = self.stringToDate(stringDate: dateStr as String)
        print(date ?? "Hahaa")
        return ChatObj(owner: name, timeS: date!, textS: text, filePathS: path)
    }
    
    func stringToDate(stringDate: String) -> Date? {
        let dateFormater = DateFormatter.init()
        dateFormater.timeZone = TimeZone(abbreviation: "WIT")
        var date = dateFormater.date(from: stringDate)
        if date == nil {
            let formatList = ["M/d/yy, h:mm:ss a", "M/d/yy, h:mm:ss"]
            for format in formatList {
                dateFormater.dateFormat = format
                date = dateFormater.date(from: stringDate)
                if date != nil {
                    return date
                }
            }
        }
        return nil
    }
    
    func arrayStringToString(arr:[String]) -> String {
        var content = ""
        for text in arr {
            content = content.appending(text)
        }
        return content
    }
}
