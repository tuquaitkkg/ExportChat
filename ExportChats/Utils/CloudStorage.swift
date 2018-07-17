//
//  CloudStorage.swift
//  ExportChats
//
//  Created by Dat Duong on 1/17/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire

class CloudStorage {

    static let shareInstance = CloudStorage()
    
    //MARK: - GET
    /// getDataFromServer
    ///
    /// - Parameters:
    ///   - nameFile: String
    ///   - percentage: callback
    ///   - completion: callback
    func getDataFromServer(nameFile: String, percentage: @escaping ((_ percentage : Double) -> ()) ,completion: @escaping ((_ data: Data?, _ error: Error?) -> ())) {
        let storage = Storage.storage()
        var storageRef = storage.reference()
        
        // Create a reference to the file we want to download
        storageRef = storageRef.child(Utils.getIdGoogle() + "/" + nameFile + "." + Constant.zipName)
        
        // Start the download (in this case writing to a file)
        let downloadTask = storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                completion(nil, error)
            } else {
                completion(data, nil)
            }
        }
        
        // Observe changes in status
        downloadTask.observe(.resume) { snapshot in
            // Download resumed, also fires when the download starts
        }
        
        downloadTask.observe(.pause) { snapshot in
            // Download paused
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Get Percentage == \(percentComplete)")
            percentage(percentComplete as Double)
        }
        
        downloadTask.observe(.success) { snapshot in
            // Download completed successfully
        }
        
        // Errors only occur in the "Failure" case
        downloadTask.observe(.failure) { snapshot in
            completion(nil, snapshot.error)
            guard let errorCode = (snapshot.error as NSError?)?.code else {
                return
            }
            guard let error = StorageErrorCode(rawValue: errorCode) else {
                return
            }
            switch (error) {
            case .objectNotFound:
                // File doesn't exist
                break
            case .unauthorized:
                // User doesn't have permission to access file
                break
            case .cancelled:
                // User cancelled the download
                break
                
                /* ... */
                
            case .unknown:
                // Unknown error occurred, inspect the server response
                break
            default:
                // Another error occurred. This is a good place to retry the download.
                break
            }
        }
    }
    
    /// getAllDataFromServer
    ///
    /// - Parameter completion: callback
    func getAllDataFromServer(completion: @escaping (([String]) -> Swift.Void)) {
        let database = Database.database()
        var listResult = [String]()
        let userID = Utils.getIdGoogle()
        let databaseRef = database.reference().child(userID)
        
        databaseRef.observe(.value) { (snapshot) in
            if snapshot.children.allObjects.count > 0 {
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    // Get download URL from snapshot
                    let url = child.value as! String
                    print("--------->path: \(url)")
                    listResult.append(url)
                    if listResult.count == snapshot.children.allObjects.count {
                        completion(listResult)
                    }
                }
            } else {
                completion(listResult)
            }
        }
    }
    
    
    //MARK: - SEND
    /// sendDataToServer
    ///
    /// - Parameters:
    ///   - filePath: String
    ///   - percentage: callback
    ///   - completion: callback
    func sendDataToServer(rootFolder: String, fileName: String, percentage: @escaping ((_ percentage : Double) -> ()) ,completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
        let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: fileName))
        let database = Database.database()
        let storage = Storage.storage()
        var storageRef = storage.reference()
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = Constant.zipName
        
        let nameFile = (fileName as NSString).lastPathComponent
        storageRef = storageRef.child(rootFolder).child(nameFile)
        
        let uploadTask = storageRef.putData(data, metadata: metadata)
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { snapshot in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            print("Upload Percentage == \(percentComplete)")
            percentage(percentComplete as Double)
        }
        
        // Handle upload success
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("Upload completed successfully")
            // When the image has successfully uploaded, we get it's download URL
            let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
            // Write the download URL to the Realtime Database
            let splitString = nameFile.components(separatedBy: ".")
            let strFirst = splitString.first
//            let user = UserModel(namePath: nameFile, urlPath: downloadURL!)
            let dbRef = database.reference().child(Utils.getIdGoogle()).child(strFirst!)
            dbRef.setValue(downloadURL)
            completion(true, nil)
        }
        
        uploadTask.observe(.failure) { snapshot in
            completion(false, snapshot.error)
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
    
    //MARK: - DELETE
    /// deleteFileFromServer
    ///
    /// - Parameters:
    ///   - nameFile: String
    ///   - completion: callback
    func deleteFileFromServer(nameFile: String, completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
        let storage = Storage.storage()
        var storageRef = storage.reference()
        
        // Create a reference to the file we want to download
        storageRef = storageRef.child(Utils.getIdGoogle() + "/" + nameFile)
        
        storageRef.delete { error in
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
                print("File deleted successfully")
            }
        }
    }
    
    // MARK: - DOWNLOAD
    
    /// downloadAllDataFromSever
    ///
    /// - Parameters:
    ///   - folderName: String
    ///   - completion: callback
    func downloadAllDataFromSever(folderName: String, completion:@escaping (((Bool) -> Swift.Void))) {
        let group = DispatchGroup()
        var error: Error?
        FileManagerUtils.removeAllZipFile()
        self.getAllDataFromServer { (listResult) in
            print("listpath: \(listResult)")
            for path in listResult {
                print("path: \(path)")
                group.enter()
                let destination = DownloadRequest.suggestedDownloadDestination()
//                let fileURL = FileManagerUtils.createFolder(folderName: folderName)
//                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//                    return (fileURL!, [.createIntermediateDirectories, .removePreviousFile])
//                }
                Alamofire.download(path, to: destination).validate().response(completionHandler: { (response) in
                    error = response.error;
                    group.leave()
                })
            }
            group.notify(queue: .main, execute: {
                if error != nil {
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }
    }
}
