//
//  AppDelegate.swift
//  ExportChats
//
//  Created by Dat Duong on 1/12/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import SSZipArchive
import MBProgressHUD
import GoogleMobileAds
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    //MARK:- GOOGLE
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let email = user.profile.email
            print("Auth:\(String(describing: idToken))\nUserId:\(String(describing: userId))\nFullname:\(String(describing: fullName))\nEmail:\(String(describing: email))")
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    //ROOT
    let appGroupName = "group.com.dtteam.ShareExtensions"
    let keyData = "keyData"
    let keyNameOfData = "keyNameOfData"
    var window: UIWindow?
    var kClient = "com.googleusercontent.apps.266015350856-941s11jd82os8tajmh4qdr0bq6pltdb6"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //IPA
        completeIAPTransactions()
        
        //Ads
        GADMobileAds.configure(withApplicationID: Constant.Ads.kAdmobAppID)
        
        //Firebase config
        FirebaseApp.configure()
        
        //GG signin
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        GIDSignIn.sharedInstance().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(processDataFromServer), name: NSNotification.Name(rawValue: "processDataFromServer"), object: nil)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            print("Open url appdelegate")
            //Processing get data from share extension
            let data = self.getDataIntoUD()
            let nameOfData = self.getNameOfDataIntoUD()
            var nameFolderOfZipFile = Constant.trashFolder
            if nameOfData != nil && data != nil {
                if Utils.getIdGoogle() != "" {
                    nameFolderOfZipFile = Utils.getIdGoogle()
                    FileManagerUtils.writeDataDocumentsFile(data: data!, nameData: nameOfData!, newFolder: nameFolderOfZipFile, completion: { (success, error) in
                        let urlPath = FileManagerUtils.getPathFromDocument(fileName: nameOfData!, folderName: nameFolderOfZipFile)
                        CloudStorage.shareInstance.sendDataToServer(rootFolder: Utils.getIdGoogle(), fileName: urlPath, percentage: { (progress) in
                            print("progress: \(progress)")
                        }, completion: { (success, error) in
                            if success {
                                self.processData()
                            }
                        })
                        print("\(String(describing: success)) error: \(String(describing: error))")
                    })
                } else {
                    FileManagerUtils.writeDataDocumentsFile(data: data!, nameData: nameOfData!, newFolder: nameFolderOfZipFile, completion: { (success, error) in
                        print("\(String(describing: success)) error: \(String(describing: error))")
                        self.processData()
                    })
                }
            }
            return GIDSignIn.sharedInstance().handle(url,
                                                        sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                        annotation: [:])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /*
        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) && UserDefaults.standard.object(forKey: Constant.keyValidDate) != nil {
            let startVC = StartVC()
            if (startVC.getDayFromDate(UserDefaults.standard.object(forKey: Constant.keyValidDate) as! Date) > 2) {
                let app = UIApplication.shared.delegate as! AppDelegate
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "StartVC") as? StartVC
                let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                navigationController.pushViewController(vc!, animated: false)
                app.window?.rootViewController = navigationController
                app.window?.makeKeyAndVisible()
            }
        }
        */
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func getDataIntoUD() -> Data? {
        let userDefault = UserDefaults(suiteName: appGroupName)
        userDefault?.synchronize()
        return userDefault?.object(forKey: keyData) as? Data
    }
    
    func getNameOfDataIntoUD() -> String? {
        let userDefault = UserDefaults(suiteName: appGroupName)
        userDefault?.synchronize()
        return userDefault?.object(forKey: keyNameOfData) as? String
    }
    
    func nameForFolder(name: String) -> String {
        var nsName = name as NSString
        if nsName.pathExtension != "" {
            nsName = nsName.replacingOccurrences(of: nsName.pathExtension, with:"") as NSString
            nsName = nsName.substring(to: nsName.length-1) as NSString
        }
        if nsName.contains("WhatsApp Chat - ") {
            nsName = nsName.replacingOccurrences(of: "WhatsApp Chat - ", with: "") as NSString
        }
        
        return nsName as String
    }
    
    @objc func processDataFromServer() {
        //Processing get data from server
        print("Processing get data from server")
        let nameFolderOfZipFile = Utils.getIdGoogle()
        let listFile = FileManagerUtils.getListFilesFromDocumentsFolder(folderName: nameFolderOfZipFile)
        if let listFile = listFile {
            var count : Int64 = 0
            for pathFile in listFile {
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                let documentsDirectory = paths[0]
                let folderName = nameForFolder(name: pathFile)
                count += 1
                let timeStamp : Int64 = Int64(Date.timeIntervalSinceReferenceDate) + count
               
                let dataPath = documentsDirectory.appending("/unzip/\(timeStamp)")
                let pathZipFile = documentsDirectory + "/" + nameFolderOfZipFile + "/" + pathFile
                let check = FileManager.default.fileExists(atPath: pathZipFile)
                if check == true {
                    SSZipArchive.unzipFile(atPath: pathZipFile, toDestination: dataPath, progressHandler: { (entry, zipInfo, entryNum, total) in
                    }) { (path, succeeded, error) in
                        print(error.debugDescription)
                        if error == nil {
                            let arrayConversation = UserDefaults.standard.array(forKey: "Conversation")
                            var array = arrayConversation as? [[String : String]]
                            let conversation = [
                                "name" : folderName,
                                "path" : "/unzip/\(timeStamp)",
                                "nameOfZipFile" : pathFile
                            ]
                            if array == nil {
                                array = [[String : String]]()
                            }
                            array?.append(conversation)
                            UserDefaults.standard.set(array, forKey: "Conversation")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: self, userInfo: nil)
                        }
                    }
                } else {
                    print("File path error")
                }
            }
        }
    }
    
    func processData() {
        //Processing get data from share extension
        print("Processing get data from share extension")
        let nameOfData = self.getNameOfDataIntoUD()
        var nameFolderOfZipFile = Constant.trashFolder
        if let nameOfData = nameOfData {
            if Utils.getIdGoogle() != "" {
                nameFolderOfZipFile = Utils.getIdGoogle()
            }

            let pathFile = FileManagerUtils.getPathFromDocument(fileName: nameOfData, folderName: nameFolderOfZipFile)
            print(pathFile)
            if pathFile != "" {
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                let documentsDirectory = paths[0]
                let folderName = nameForFolder(name: nameOfData)
                let timeStamp : Int64 = Int64(Date.timeIntervalSinceReferenceDate)
                let dataPath = documentsDirectory.appending("/unzip/\(timeStamp)")
                
                let check = FileManager.default.fileExists(atPath: pathFile)
                if check == true {
                    SSZipArchive.unzipFile(atPath: pathFile, toDestination: dataPath, progressHandler: { (entry, zipInfo, entryNum, total) in
                    }) { (path, succeeded, error) in
                        print(error.debugDescription)
                        if error == nil {
                            let arrayConversation = UserDefaults.standard.array(forKey: "Conversation")
                            var array = arrayConversation as? [[String : String]]
                            let conversation = [
                                "name" : folderName,
                                "path" : "/unzip/\(timeStamp)",
                                "nameOfZipFile" : nameOfData
                            ]
                            if array == nil {
                                array = [[String : String]]()
                            }
                            
                            let itemForDelete = array?.filter{ $0["nameOfZipFile"] == nameOfData}.first
                            if let itemForDelete = itemForDelete {
                                FileManagerUtils.removeLocalFolder(conversationInfo: itemForDelete)
                            }
                            array = array?.filter{ $0["nameOfZipFile"] != nameOfData}
                            array?.append(conversation)
                            UserDefaults.standard.set(array, forKey: "Conversation")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: self, userInfo: nil)
                        }
                    }
                } else {
                    print("File path error")
                }
            }
        }
    }
    
    func completeIAPTransactions() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase.productId)")
                }
            }
        }
    }
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "coreDataTestForPreOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "coreDataTestForPreOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if #available(iOS 10.0, *) {
            
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // iOS 9.0 and below - however you were previously handling it
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            
        }
    }
}

