//
//  PurchaseVC.swift
//  CallSantaChristmas
//
//  Created by Dat Duong on 12/9/17.
//  Copyright © 2017 Dat Duong. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class PurchaseVC: UIViewController {

    var indexClick: Int?
    let appBundleId = "com.dtteam.ShareExtensions.sub.allaccess"
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.isHidden = true
    }

    @IBAction func purchaseBtn(_ sender: Any) {
        self.purchase()
    }
    
    @IBAction func restoreBtn(_ sender: Any) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()

            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                // Deliver content from server, then:
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }
    
    @IBAction func closeInApp(_ sender: Any) {
        self.callTabbarStoryboard()
    }
    
    @IBAction func policyBtn(_ sender: Any) {
        indexClick = 1
        self.performSegue(withIdentifier: "idfShowInfoPage", sender: self)
    }
    
    @IBAction func aboutBtn(_ sender: Any) {
        indexClick = 2;
        self.performSegue(withIdentifier: "idfShowInfoPage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "idfShowInfoPage" {
            let vc = segue.destination as? InfoPageVC
            vc?.index = indexClick
        }
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continuesAction = UIAlertAction(title: "Continues", style: .destructive) { (alertAction) in
            if UserDefaults.standard.object(forKey: Constant.keyValidDate) == nil {
                UserDefaults.standard.set(Date(), forKey: Constant.keyValidDate)
            }
            self.callTabbarStoryboard()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(continuesAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func callTabbarStoryboard() {
        let tabbarSB = UIStoryboard(name: "Tabbar", bundle: nil)
        let viewcontroller : UITabBarController = tabbarSB.instantiateViewController(withIdentifier: "Tabbar") as! UITabBarController
//        if self.changePassCode {
//            viewcontroller.selectedIndex = 1
//        }
        UIApplication.shared.windows.first?.rootViewController = viewcontroller
    }
    
    open func nextVC() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PassCodeOptionVC") as? PassCodeOptionVC
        let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
        navigationController.pushViewController(vc!, animated: false)
        app.window?.rootViewController = navigationController
        app.window?.makeKeyAndVisible()
    }
    
    //MARK:- Purchase
    func purchase() {
        self.progressView.isHidden = false
        self.progressView.startAnimating()
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(appBundleId, atomically: true) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.progressView.isHidden = true
                self.progressView.stopAnimating()
                self.showAlert(alert)
            }
        }
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alertAction) in
            //Show Main
            if UserDefaults.standard.bool(forKey: "keyPurchase") {
                self.gotoMain()
            }
            
        }))
        return alert
    }
    
    func gotoMain() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let tabbarSB = UIStoryboard(name: "Tabbar", bundle: nil)
        let viewcontroller : UITabBarController = tabbarSB.instantiateViewController(withIdentifier: "Tabbar") as! UITabBarController
        viewcontroller.selectedIndex = 0
        app.window?.rootViewController = viewcontroller
        app.window?.makeKeyAndVisible()
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            UserDefaults.standard.set(true, forKey: "keyPurchase")
            UserDefaults.standard.set(Date(), forKey: "keyDate")
//            print("Purchase Success: \(purchase.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
//            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                self.progressView.isHidden = true
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
//            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
//            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
}
