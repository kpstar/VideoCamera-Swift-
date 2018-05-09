//
//  LogInViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/7/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    let mUsername : String? = UserDefaults.standard.string(forKey: kUsername) ?? ""
    let mPassword : String? = UserDefaults.standard.string(forKey: kPassword) ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = UIColor.init(red: 240/255.0, green: 248/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        registerBtn.layer.cornerRadius = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        if mUsername != "" {
            let desVC = main.instantiateViewController(withIdentifier: "Passcode") as! PasscodeViewController
            UserDefaults.standard.set("2", forKey: kCodeStatus)
            self.navigationController?.pushViewController(desVC, animated: false)
        }
    }
    
    @IBAction func registerBtnTapped(_ sender: UIButton) {
        if let user = usernameTxt.text {
            UserDefaults.standard.set(user, forKey: kUsername)
            UserDefaults.standard.set(passwordTxt.text, forKey: kPassword)
        } else {
            displayMyAlertMessage(titleMsg: "Alert", alertMsg: "Please insert your name")
            return
        }
        
        let desVC = main.instantiateViewController(withIdentifier: "Passcode") as! PasscodeViewController
        UserDefaults.standard.set("0", forKey: kCodeStatus)
        self.navigationController?.pushViewController(desVC, animated: true)
    }
}
