//
//  HomeVC.swift
//  ExportChats
//
//  Created by DatDuong on 1/22/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import MBProgressHUD
import SSZipArchive
import SWTableViewCell
import Floaty
import GoogleMobileAds

class HomeVC: UIViewController, GADInterstitialDelegate {
    

    @IBOutlet weak var tbvChats: UITableView!
    var listResult = [String]()
    var listConversation : [[String : String]]?
    var listData : [CellItem]?
    let appGroupName = "group.com.dtteam.ShareExtensions"
    let keyNameOfData = "keyNameOfData"
    var rootPath = ""
    var floaty = Floaty()
    var interstitial: GADInterstitial!
    var click = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //init admob
        self.tabBarController?.tabBar.isHidden = true
        let newBtn = UIBarButtonItem(image: UIImage.init(named: "settings"), style: .plain, target: self, action: #selector(goToSetting))
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = newBtn
        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
            interstitial = createAndLoadInterstitial()
        }
        
        //Register cell in tbv
        self.tbvChats.delegate = self;
        self.tbvChats.dataSource = self;
//        self.tbvChats.register(UINib(nibName: "ChatsTbvCell", bundle: nil), forCellReuseIdentifier: "ChatsTbvCell")
        
        //Init Chats
        title = "Chats"
        navigationController?.navigationBar.tintColor = UIColor.white
        listConversation = UserDefaults.standard.array(forKey: "Conversation") as? [[String : String]]
        print(listConversation ?? "List conversation is nil")
        processMessage()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(rawValue: "reloadTableView"), object: nil)
        self.tbvChats.register(UINib.init(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as String
        
        do {
            let documentContent = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory)
            if documentContent.count > 0 {
                for item in documentContent {
                    print(item)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        self.layoutFAB()
    }
    
    @objc func goToSetting() {
        let tabbarSB = UIStoryboard(name: "Tabbar", bundle: nil)
        let viewcontroller : UIViewController = tabbarSB.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    //add float button
    func layoutFAB() {
        let floaty = Floaty()
        floaty.buttonColor = UIColor(red: 19.0/225.0, green: 180.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        floaty.paddingY = 65
        floaty.buttonImage = UIImage(named: "plus")!
        floaty.addItem("Go to WhatApp", icon: UIImage(named: "whatsapp")!, handler: { item in
            let whatsappURL = URL(string: "https://api.whatsapp.com")
            if let url = whatsappURL {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL)
                } else {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            floaty.close()
        })
        self.view.addSubview(floaty)
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: Constant.Ads.kAdmobInterstitial)
        interstitial.delegate = self
        let req = GADRequest()
//        req.testDevices = ["4dce668b63cf17c727c407af71deecee", kGADSimulatorID]
        interstitial.load(req)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func reloadTableView() {
        listConversation = UserDefaults.standard.array(forKey: "Conversation") as? [[String : String]]
        processMessage()
        self.tbvChats.reloadData()
    }
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listData = listData {
            return listData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ConversationTableViewCell
        cell.delegate = self
        if let list = listData {
            let item = list[indexPath.row]
            cell.lblName.text = item.name
            if item.text == ""{
                cell.lblText.text = "attack file"
            } else {
                cell.lblText.text = item.text
            }
            let day : Int = Int((Date().timeIntervalSinceReferenceDate - (item.time?.timeIntervalSinceReferenceDate)!)/(24 * 60 * 60))
            let hour : Int = Int((Date().timeIntervalSinceReferenceDate - (item.time?.timeIntervalSinceReferenceDate)!)/(60 * 60))
            let minute : Int = Int((Date().timeIntervalSinceReferenceDate - (item.time?.timeIntervalSinceReferenceDate)!)/(60))
            let second : Int = Int((Date().timeIntervalSinceReferenceDate - (item.time?.timeIntervalSinceReferenceDate)!))
            if day > 0 {
                cell.lblHour.text = "\(day) days"
                
            } else if hour > 0 {
                cell.lblHour.text =  "\(hour) hours"
            } else if minute > 0 {
                cell.lblHour.text =  "\(minute) minutes"
            } else {
                cell.lblHour.text =  "\(second) seconds"
            }
        }
        
        let rightButtons = NSMutableArray.init()
        rightButtons.sw_addUtilityButton(with: UIColor.lightGray, title: "More")
        rightButtons.sw_addUtilityButton(with: UIColor.red, title: "Delete")
        cell.rightUtilityButtons = rightButtons as! [Any]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
            if interstitial.isReady {
                if click == 0 {
                    click += 1
                    interstitial.present(fromRootViewController: self)
                } else {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    vc.senderID = "\(indexPath.row)"
                    vc.conversationInfo = listConversation![indexPath.row]
                    self.click = 0
                    navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                print("is Showing")
                let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.senderID = "\(indexPath.row)"
                self.click = 0
                vc.conversationInfo = listConversation![indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.senderID = "\(indexPath.row)"
            self.click = 0
            vc.conversationInfo = listConversation![indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

extension HomeVC: SWTableViewCellDelegate {
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        let indexCell = tbvChats.indexPath(for: cell)?.row
        if index == 1 {
            print("action")
            let alert = UIAlertController(title: "Delete conversation", message: "Do you want to delete this conversation?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                if let nameFileZip = self.listConversation![indexCell!]["nameOfZipFile"] {
                    CloudStorage.shareInstance.deleteFileFromServer(nameFile: nameFileZip, completion: { (success, error) in
                        print("delete success")
                    })
                }
                FileManagerUtils.removeLocalFolderAndZipFile(conversationInfo: self.listConversation![indexCell!])
                self.listConversation?.remove(at: indexCell!)
                UserDefaults.standard.set(self.listConversation, forKey: "Conversation")
                self.listData?.remove(at: indexCell!)
                self.tbvChats.reloadData()
            }))
            
            self.present(alert, animated: true)
        } else {
            print("action")
            let alert = UIAlertController(title: "ExportChatApp", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Export chat", style: .destructive, handler: { action in
                print("sent path")
                if let nameFileZip = self.listConversation![indexCell!]["nameOfZipFile"] {
                    let path = FileManagerUtils.getPathFromDocument(fileName: nameFileZip, folderName: Utils.getIdGoogle())
                    if path != "" {
                        let objectsToShare = [NSURL(fileURLWithPath: path)]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        self.present(activityVC, animated: true, completion: nil)
                    } else {
                        self.alert(title: "Error!", message: "Link path not found.")
                    }
                }
            }))
            self.present(alert, animated: true)
        }
    }
}
    
//MARK:-Process Message
extension HomeVC {
    func share(message: String, link: String) {
        if let link = NSURL(string: link) {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    func processMessage() {
        listData = [CellItem]()
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0]
        rootPath = documentsDirectory
        if let listConversation = listConversation {
            for conversationInfo in listConversation {
                if let path = conversationInfo["path"] {
                    let urlFolderUnzip = URL.init(string: documentsDirectory.appending(path))
                    do {
                        let fileURLs = try FileManager.default.contentsOfDirectory(at: urlFolderUnzip!, includingPropertiesForKeys: nil)
                        if fileURLs.count > 0 {
                            for urlFile in fileURLs {
                                if urlFile.lastPathComponent == "_chat.txt" {
                                    do {
                                        let stringContent = try String.init(contentsOfFile: urlFile.path)
                                        print(stringContent)
                                        let sentenceArr = stringContent.components(separatedBy: "\n")
                                        let sentenceObj = CommonUtils().conversationWithArrayChat(sentenceArr, andPathFile: conversationInfo["path"]!)
                                        print(sentenceObj.chats as Any)
                                        if let chat = sentenceObj.chats {
                                            let item = chat.max(by: { (a, b) -> Bool in
                                                a.time < b.time
                                            })
                                            listData?.append(CellItem(aname: conversationInfo["name"]!, atext: (item?.text)!, atime: (item?.time)!))
                                        }
                                    } catch let error {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

class CellItem: NSObject {
    var name : String!
    var text : String?
    var time : Date?
    
    init(aname: String, atext: String, atime: Date ) {
        name = aname
        text = atext
        time = atime
    }
}
