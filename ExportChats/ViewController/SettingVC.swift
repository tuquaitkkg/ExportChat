//
//  SettingVC.swift
//  ExportChats
//
//  Created by DatDuong on 1/22/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
import SwiftyStoreKit

class SettingVC: UIViewController {

    @IBOutlet weak var tbvSettings: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var listData = [String]()
    var clickIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbvSettings.separatorStyle = .none
        self.setUp()
        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
            self.loadBanner()
        }
    }
    
    func setUp() {
        if UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
            self.listData.append("Change Passcode")
//            self.listData.append("Privacy Policy")
//            self.listData.append("Terms of Use")
            self.listData.append("Support")
            self.listData.append("Share this app")
            self.listData.append("Restore Puchase")
        } else {
            self.listData.append("Change Passcode")
            self.listData.append("Support")
            self.listData.append("Share this app")
            self.listData.append("How To Use")
        }
    }
    
    func loadBanner() {
        //load banner
        bannerView.adUnitID = Constant.Ads.kAdmobBanner
        bannerView.rootViewController = self
        let req = GADRequest()
//        req.testDevices = ["4dce668b63cf17c727c407af71deecee", kGADSimulatorID]
        bannerView.load(req)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "touIdf" {
            let vc = segue.destination as? TOUAndPolicyVC
//            if clickIndex == 1 {
//                vc?.lbTitle.text = "Privacy Policy"
//                vc?.textContent = Constant.Info.infoOfPolicy
//            } else if clickIndex == 2 {
//                vc?.lbTitle.text = "Terms of Use"
//                vc?.textContent = Constant.Info.infoOfTOU
//            }
            //how to use
            vc?.lbTitle.text = "How to use"
            vc?.textContent = Constant.Info.infoHowToUse
        }
    }

}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as? SettingsTbvCell
        cell?.selectionStyle = .none
        cell?.lbName.text = self.listData[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
//            self.clickIndex = 0
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller : PassCodeVC = mainSB.instantiateViewController(withIdentifier: "PassCodeVC") as! PassCodeVC
            viewcontroller.isChangePassCode = true
            self.navigationController?.pushViewController(viewcontroller, animated: true)
            break
//        case 1:
//            self.clickIndex = 1
//            self.openVC(nameVC: "touIdf")
//            break
//        case 2:
//            self.clickIndex = 2
//            self.openVC(nameVC: "touIdf")
//            break
        case 1:
//            self.clickIndex = 3
            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                return
            }
            sendEmail()
            break
        case 2:
            //Share
            self.share(message: "Export Chats", link: "https://itunes.apple.com/us/app/myapp/idxxxxxxxx?ls=1&mt=8")
            break;
        default:
            if UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
                NetworkActivityIndicatorManager.networkOperationStarted()
                SwiftyStoreKit.restorePurchases(atomically: true) { results in
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    
                    for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.showAlert(self.alertForRestorePurchases(results))
                }
            } else {
                self.walkThroughtScreeen()
            }
            break;
        }
    }
    
    //Action
    
    func openVC(nameVC: String) {
        self.performSegue(withIdentifier: nameVC, sender: self)
    }
    
    func share(message: String, link: String) {
        if let link = NSURL(string: link) {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //purchase
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alertAction) in
            if UserDefaults.standard.bool(forKey: Constant.keyRestore) {
                let app = UIApplication.shared.delegate as! AppDelegate
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "StartVC") as? StartVC
                let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                navigationController.pushViewController(vc!, animated: false)
                app.window?.rootViewController = navigationController
                app.window?.makeKeyAndVisible()
            }
            
        }))
        return alert
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            UserDefaults.standard.removeObject(forKey: Constant.keyPurchase)
            UserDefaults.standard.removeObject(forKey: Constant.keyValidDate)
            UserDefaults.standard.removeObject(forKey: Constant.keyPurchaseValidDate)
            UserDefaults.standard.set(true, forKey: Constant.keyRestore)
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func walkThroughtScreeen() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard.init(name: "Page", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PageVC") as! PageVC
        let navigationController = storyboard.instantiateViewController(withIdentifier: "PageNav") as! UINavigationController
        navigationController.pushViewController(viewController, animated: false)
        app.window?.rootViewController = navigationController
        app.window?.makeKeyAndVisible()
    }
    
}

extension SettingVC: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["thaydoidetieptucphattrien@gmail.com"])
        composeVC.setSubject("ExportChats")
//        composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
