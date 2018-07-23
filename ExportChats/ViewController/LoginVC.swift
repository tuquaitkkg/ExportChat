//
//  LoginVC.swift
//  ExportChats
//
//  Created by DatDuong on 1/24/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import MBProgressHUD
import GoogleSignIn
import GoogleMobileAds

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, GADInterstitialDelegate {
    var changePassCode = false
    @IBOutlet weak var loginBtn: UIButton!
    var interstitial: GADInterstitial!
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID
            print("userId: \(String(describing: userId))")
            if (userId != nil) {
                UserDefaults.standard.set(userId, forKey: Constant.udKey.key_user_id_google)
                self.loginBtn.isHidden = true
                self.showHud("Please wait...")
                self.progressWhenLogin(completion: { (success) in
                    self.hideHUD()
                    if UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
                        self.callTabbarStoryboard()
                    } else {
                        self.performSegue(withIdentifier: "purchaseIdf2", sender: nil)
                    }
                    
                })
            }
            /*
            let idToken = user.authentication.idToken
            let fullName = user.profile.name
            let profilePicture = String(describing: GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 400))
            let email = user.profile.email
            */
        } else {
            print("\(error.localizedDescription)")
            alert(title: "Error!!", message: "There was an error signing in...")
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        loginBtn.layer.masksToBounds = true
        loginBtn.layer.cornerRadius = loginBtn.frame.size.height/2
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
            interstitial = createAndLoadInterstitial()
        }
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
         GIDSignIn.sharedInstance().signIn()
        interstitial = createAndLoadInterstitial()
    }
    
    func showHud(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        hud.animationType = .fade
        hud.offset.y = 200
        hud.isUserInteractionEnabled = false
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    @IBAction func signInToGoogle(sender: AnyObject) {
//        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
//            if interstitial.isReady {
//                interstitial.present(fromRootViewController: self)
//            } else {
//                print("is Showing")
//                GIDSignIn.sharedInstance().signIn()
//            }
//        } else {
//            GIDSignIn.sharedInstance().signIn()
//        }
        if UserDefaults.standard.bool(forKey: "isTutorial") == false {
            self.performSegue(withIdentifier: "showTutorial", sender: nil)
        } else {
            if UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
                self.callTabbarStoryboard()
            } else {
                self.performSegue(withIdentifier: "purchaseIdf2", sender: nil)
            }

        }
        
            /*
             let idToken = user.authentication.idToken
             let fullName = user.profile.name
             let profilePicture = String(describing: GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 400))
             let email = user.profile.email
             */

    }
    
    func progressWhenLogin(completion: @escaping (((Bool) -> Swift.Void))) {
        FileManagerUtils.copyItemFromTrashChatToRoot { (succes) in
            if succes {
                CloudStorage.shareInstance.downloadAllDataFromSever(folderName: Utils.getIdGoogle(), completion: { (success) in
                    if succes {
                        FileManagerUtils.copyFileIntoDic(completion: { (success) in
                            print("success: \(success)")
                            if success {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "processDataFromServer"), object: self, userInfo: nil)
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    }
                })
            } else {
                completion(false)
            }
        }
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func callTabbarStoryboard() {
        let tabbarSB = UIStoryboard(name: "Tabbar", bundle: nil)
        let viewcontroller : UITabBarController = tabbarSB.instantiateViewController(withIdentifier: "Tabbar") as! UITabBarController
        UIApplication.shared.windows.first?.rootViewController = viewcontroller
    }
}
