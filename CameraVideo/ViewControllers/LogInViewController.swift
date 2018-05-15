//
//  LogInViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/7/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    let mUsername : String? = UserDefaults.standard.string(forKey: kUsername) ?? ""
    let mPassword : String? = UserDefaults.standard.string(forKey: kPassword) ?? ""
    let mPasscode : String? = UserDefaults.standard.string(forKey: kPasscode) ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = UIColor.init(red: 240/255.0, green: 248/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        registerBtn.layer.cornerRadius = 3
        
        signInBtn.layer.borderWidth = 1
        signInBtn.layer.borderColor = UIColor.init(red: 240/255.0, green: 248/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        signInBtn.layer.cornerRadius = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        let mUser : String? = UserDefaults.standard.string(forKey: kUsername) ?? ""
        let mPass : String? = UserDefaults.standard.string(forKey: kPasscode) ?? ""
        if mUser != "" && mPass != "" {
            let desVC = main.instantiateViewController(withIdentifier: "Passcode") as! PasscodeViewController
            UserDefaults.standard.set("2", forKey: kCodeStatus)
            self.navigationController?.pushViewController(desVC, animated: false)
        }
    }
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.detailsLabel.text = "Please wait..."
        
        var errorMsg : String? = ""
        
        let username = usernameTxt.text
        let password = passwordTxt.text
        
        if username == "" {
            errorMsg = "Please insert username."
        }
        
        if password == "" {
            errorMsg = "Please insert password."
        }
        
        if errorMsg != "" {
            displayMyAlertMessage(titleMsg: "Alert", alertMsg: errorMsg!)
            return
        }
        
        let params: [String: Any] = [
            "name": username!,
            "password": password!
        ]
        
        let url: String = kWebsiteUrl + kLoginUrl
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            
            progress.hide(animated: true)
            guard let statusCode = response.response?.statusCode else {
                self.displayMyAlertMessage(titleMsg: "Error", alertMsg: "Please check network connection")
                return
            }
            if statusCode == 200 {
                let json = response.result.value as! Dictionary<String, Any>
                let dic_token = json["success"] as! Dictionary<String , Any>
                let token = dic_token["token"] as! String
                print(token)
                
                UserDefaults.standard.set(username, forKey: kUsername)
                UserDefaults.standard.set(password, forKey: kPassword)
                UserDefaults.standard.set("0", forKey: kCodeStatus)
                UserDefaults.standard.set(token, forKey: kToken)
                let desVC = main.instantiateViewController(withIdentifier: "Passcode") as! PasscodeViewController
                self.navigationController?.pushViewController(desVC, animated: true)
            } else {
                self.displayMyAlertMessage(titleMsg: "Error", alertMsg: "Username or Password is incorrect.")
            }
        }
        
        usernameTxt.text = ""
        passwordTxt.text = ""
    }
    
    @IBAction func registerBtnTapped(_ sender: UIButton) {
        
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.detailsLabel.text = "Please wait..."
        
        var errorMsg : String? = ""
        
        let username = usernameTxt.text
        let password = passwordTxt.text
        
        if username == "" {
            errorMsg = "Please insert username."
        }
        
        if password == "" {
            errorMsg = "Please insert password."
        }
        
        if errorMsg != "" {
            displayMyAlertMessage(titleMsg: "Alert", alertMsg: errorMsg!)
            return
        }
        
        let params: [String: Any] = [
            "name": username!,
            "password": password!
        ]
        

        let url: String = kWebsiteUrl + kRegUrl
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            
            progress.hide(animated: true)
            guard let statusCode = response.response?.statusCode else {
                self.displayMyAlertMessage(titleMsg: "Error", alertMsg: "Please check network connection")
                return
            }
            
            guard let _ = response.result.value as? Dictionary<String, Any> else {
                self.displayMyAlertMessage(titleMsg: "Error", alertMsg: "Please check network connection.")
                return
            }
            if statusCode == 200 {
                let json = response.result.value as! Dictionary<String, Any>
                let dic_token = json["success"] as! Dictionary<String , Any>
                let token = dic_token["token"] as! String
                
                UserDefaults.standard.set(username, forKey: kUsername)
                UserDefaults.standard.set(password, forKey: kPassword)
                UserDefaults.standard.set("0", forKey: kCodeStatus)
                UserDefaults.standard.set(token, forKey: kToken)
                let desVC = main.instantiateViewController(withIdentifier: "Passcode") as! PasscodeViewController
                self.navigationController?.pushViewController(desVC, animated: true)
            } else {
                self.displayMyAlertMessage(titleMsg: "Error", alertMsg: "Username already Exists")
            }
        }
        usernameTxt.text = ""
        passwordTxt.text = ""
    }
}
