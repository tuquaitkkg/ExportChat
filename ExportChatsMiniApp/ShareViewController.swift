//
//  ShareViewController.swift
//  ExportCharts
//
//  Created by ToanNT on 1/14/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    let appGroupName = "group.com.dtteam.ShareExtensions"
    let keyData = "keyData"
    let keyNameOfData = "keyNameOfData"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getZipPathFromWhatApp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    func openCustomURLScheme(customURLScheme: String) {
        let customURL = NSURL.init(string: customURLScheme)
        if let url = customURL {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    
    override func didSelectPost() {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        openCustomURLScheme(customURLScheme: "chatapp://")
    }
    
    override func configurationItems() -> [Any]! {
        return []
    }
    
    private func getZipPathFromWhatApp() {
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        let zip_type = String(kUTTypeZipArchive)
        if itemProvider.hasItemConformingToTypeIdentifier(zip_type) {
            itemProvider.loadItem(forTypeIdentifier: zip_type, options: nil, completionHandler: { (item, error) -> Void in
                guard let url = item as? NSURL else { return }
                print("\(item.debugDescription)")
                OperationQueue.main.addOperation {
                    let path = url as URL
                    print("path: \(path)")
                    do {
                        let data = try Data.init(contentsOf: path, options: .mappedIfSafe)
                        print("data: \(data)")
                        self.saveDataToUD(data: data)
                        self.saveNameOfDataToUD(urlPath: path)
                        self.didSelectPost()
                    } catch let error as NSError {
                        print("error: \(error.description)")
                    }
                    
                }
            })
        } else {
            print("error")
        }
    }
    
    func saveDataToUD(data: Data) {
        let userDefault = UserDefaults(suiteName: appGroupName)
        userDefault?.set(data, forKey: keyData)
        userDefault?.synchronize()
    }
    
    func saveNameOfDataToUD(urlPath: URL) {
        let userDefault = UserDefaults(suiteName: appGroupName)
        userDefault?.set(urlPath.lastPathComponent, forKey: keyNameOfData)
        userDefault?.synchronize()
    }
}

class FileZip: NSObject {
    var name : String
    var path : String
    var id : Int
    
    override init() {
        name = ""
        path = ""
        id = 0
    }
    
    func initWith(name: String, path: String, id: Int ) {
        self.name = name
        self.path = path
        self.id = id
    }
}
