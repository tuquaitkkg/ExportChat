//
//  PassCodeVC.swift
//  ExportChats
//
//  Created by DatDuong on 1/22/18.
//  Copyright © 2018 Dat Duong. All rights reserved.
//

import UIKit
import SmileLock
import GoogleMobileAds

class PassCodeVC: UIViewController {
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    var isChangePassCode = false
    open var kPasswordDigit = 6
    //MARK: Outlet
    @IBOutlet weak var viewPasscode: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(withDigit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.touchAuthenticationEnabled = true
        passwordContainerView.passwordDotView.fillColor = UIColor.white
        passwordContainerView.passwordDotView.strokeColor = UIColor.white
        passwordContainerView.deleteButton?.setImage(UIImage(named: "ic_passcode2")!, for: .normal)
        passwordContainerView.deleteButton?.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        passwordContainerView.deleteButton?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        passwordContainerView.touchAuthenticationButton?.setImage(UIImage(named: "ic_passcode1")!, for: .normal)
        passwordContainerView.touchAuthenticationButton?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        passwordContainerView.passwordInputViews.forEach { view in
            view.highlightTextColor = UIColor(red: 50/255, green: 152/255, blue: 253/255, alpha: 1)
            view.highlightBackgroundColor = UIColor.white
            view.textColor = UIColor(red: 50/255, green: 152/255, blue: 253/255, alpha: 1)
            view.backgroundColor = UIColor.white
            view.layoutSubviews()
        }
        passwordContainerView.deleteButtonLocalizedTitle = ""
        passwordContainerView.frame = CGRect(x: 0, y: 0, width: self.viewPasscode.frame.size.width, height: self.viewPasscode.frame.size.height)
        self.viewPasscode.addSubview(passwordContainerView)
        if !UserDefaults.standard.bool(forKey: Constant.keyPurchase) {
            self.loadBanner()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadBanner() {
        //load banner
        bannerView.adUnitID = Constant.Ads.kAdmobBanner
        bannerView.rootViewController = self
        let req = GADRequest()
//        req.testDevices = ["4dce668b63cf17c727c407af71deecee", kGADSimulatorID]
        bannerView.load(req)
    }

    //Function
    func nextVC() {
        if isChangePassCode {
            let tabbarSB = UIStoryboard(name: "Tabbar", bundle: nil)
            let viewcontroller : UITabBarController = tabbarSB.instantiateViewController(withIdentifier: "Tabbar") as! UITabBarController
            viewcontroller.selectedIndex = 1
            UIApplication.shared.windows.first?.rootViewController = viewcontroller
        } else {
            let userID = UserDefaults.standard.object(forKey: Constant.udKey.key_user_id_google) as? String
            let isPurchase = UserDefaults.standard.bool(forKey: Constant.keyPurchase)
            if userID != nil {
                let vc = LoginVC()
                if self.isChangePassCode {
                    vc.changePassCode = true
                }
                if isPurchase {
                    vc.callTabbarStoryboard()
                } else {
                    self.performSegue(withIdentifier: "purchaseIdf", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "LoginIdf", sender: self)
            }
        }
    }
}

//MARK: Extension
extension PassCodeVC: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}
    
private extension PassCodeVC {
    func validation(_ input: String) -> Bool {
        if kPasswordDigit == 4 {
            if isChangePassCode {
                UserDefaults.standard.removeObject(forKey: Constant.udKey.key_passcode_6degit)
                UserDefaults.standard.set(input, forKey: Constant.udKey.key_passcode_4degit)
                return true
            } else {
                if let key4Degits = UserDefaults.standard.value(forKey: Constant.udKey.key_passcode_4degit) as? String {
                    if (key4Degits.isEqualToString(find: input)) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    UserDefaults.standard.set(input, forKey: Constant.udKey.key_passcode_4degit)
                    return true
                }
            }
            
        } else {
            if isChangePassCode {
                UserDefaults.standard.removeObject(forKey: Constant.udKey.key_passcode_4degit)
                UserDefaults.standard.set(input, forKey: Constant.udKey.key_passcode_6degit)
                return true
            } else {
                if let key6Degits = UserDefaults.standard.value(forKey: Constant.udKey.key_passcode_6degit) as? String {
                    if (key6Degits.isEqualToString(find: input)) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    UserDefaults.standard.set(input, forKey: Constant.udKey.key_passcode_6degit)
                    return true
                }
            }
        }
    }
    
    func validationSuccess() {
        print("success!")
        self.nextVC()
        dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        print("failure!")
        passwordContainerView.wrongPassword()
    }
}
