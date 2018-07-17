//
//  FileManagerUtils.swift
//  ExportChats
//
//  Created by DatDuong on 1/25/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit

class FileManagerUtils: NSObject {

    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
            return filePath
        } else {
            return nil
        }
    }
    
    static func removeAllZipFile() {
        do {
            let documentsUrl = self.documentsDir()
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: documentsUrl as String)
            let zipFiles = directoryContents.filter{ $0.pathExtension == Constant.zipName}
            for file in zipFiles {
                let pathFile = self.documentsDir().appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: pathFile)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func copyItemFromTrashChatToRoot(completion: ((Bool) -> Swift.Void)){
        do {
            let documentsUrl = self.createFolder(folderName: Constant.trashFolder)
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: (documentsUrl?.path)!)
            let newDic = self.createFolder(folderName: Utils.getIdGoogle())
            // if you want to filter the directory contents you can do like this:
            let zipFiles = directoryContents.filter{ $0.pathExtension == Constant.zipName}
            print("zip urls:", zipFiles)
            if zipFiles.count > 0 {
                for file in zipFiles {
                    let fromFile = documentsUrl?.appendingPathComponent(file)
                    let toFile = newDic?.appendingPathComponent(file)
                    if checkFileExist(path: (toFile?.path)!) {
                        try FileManager.default.removeItem(atPath: (fromFile?.path)!)
                    } else {
                        try FileManager.default.copyItem(atPath: (fromFile?.path)!, toPath: (toFile?.path)!)
                        try FileManager.default.removeItem(atPath: (fromFile?.path)!)
                    }
                    if file.isEqualToString(find: zipFiles.last!) {
                        completion(true)
                    }
                }
            } else {
                completion(true)
            }
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    static func copyFileIntoDic(completion: ((Bool) -> Swift.Void)) {
        do {
            let documentsUrl = self.documentsDir()
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: documentsUrl as String)
            let newDic = self.createFolder(folderName: Utils.getIdGoogle())
            // if you want to filter the directory contents you can do like this:
            let zipFiles = directoryContents.filter{ $0.pathExtension == Constant.zipName}
            print("zip urls:", zipFiles)
            if zipFiles.count > 0 {
                for file in zipFiles {
                    let fromFile = self.documentsDir().appendingPathComponent(file)
                    let toFile = newDic?.appendingPathComponent(file)
                    if checkFileExist(path: (toFile?.path)!) {
                        try FileManager.default.removeItem(atPath: fromFile)
                    } else {
                        try FileManager.default.copyItem(atPath: fromFile, toPath: (toFile?.path)!)
                        try FileManager.default.removeItem(atPath: fromFile)
                    }
                    if file.isEqualToString(find: zipFiles.last!) {
                        completion(true)
                    }
                }
            } else {
                completion(true)
            }
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    static func getListFilesFromDocumentsFolder(folderName: String) -> [String]? {
        var listPath = [String]()
        let documentsUrl = self.documentsDir().appending("/" + folderName)
        let listFile = try? FileManager.default.contentsOfDirectory(atPath:documentsUrl)
        for file in listFile! {
//            listPath.append(documentsUrl.appending(file))
            listPath.append(file)
        }
        return listPath
    }
    
    static func writeDataDocumentsFile(data:Data, nameData: String, newFolder: String, completion: @escaping ((_ success: Bool?, _ error: Error?) -> Swift.Void)) {
        let documentsPath = self.createFolder(folderName: newFolder)
        let path = documentsPath?.appendingPathComponent(nameData)
        do {
            try data.write(to: path!)
            completion(true, nil)
        } catch let error as NSError {
            print("Couldn't copy file to final location! Error:\(error.description)")
            completion(false, error)
        }
    }
    
    static func getPathFromDocument(fileName:String, folderName: String) -> String {
        let path = self.documentsDir().appendingPathComponent("/\(folderName)/\(fileName)")
        if self.checkFileExist(path: path) {
            return path
        } else {
            return ""
        }
    }
    
    static func checkFileExist(path: String) -> Bool {
        let checkValidation = FileManager.default
        if checkValidation.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }
    
    static func documentsDir() -> NSString {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [NSString]
        return paths[0]
    }
    
    static func cachesDir() -> NSString {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [NSString]
        return paths[0]
    }
    
    static func removeLocalFolderAndZipFile( conversationInfo : [String : String]) {
        let folderName = conversationInfo["path"]
        let zipFileName = conversationInfo["nameOfZipFile"]
        do {
            if folderName != nil {
                try FileManager.default.removeItem(atPath: (documentsDir() as String) + folderName!)
            }
            
            if zipFileName != nil {
                try FileManager.default.removeItem(atPath: (documentsDir() as String) + "/" + Utils.getIdGoogle() + "/" + zipFileName!)
            }
        } catch let error {
            print("Error remove local folder and zip file " + error.localizedDescription)
        }
    }
    
    static func removeLocalFolder( conversationInfo : [String : String]) {
        let folderName = conversationInfo["path"]
        do {
            try FileManager.default.removeItem(atPath: (documentsDir() as String) + folderName!)
        } catch let error {
            print("Error remove local folder " + error.localizedDescription)
        }
    }
}
