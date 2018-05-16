//
//  MenuViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/8/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import AVFoundation
import Gradientable
import KYDrawerController

class MenuViewController: UIViewController {

    @IBOutlet weak var titleView: GradientableView!
    @IBOutlet weak var logoView: GradientableView!
    @IBOutlet weak var menuTbl: UITableView!
    var menuList = [MenuType]()
    
    var drawer: KYDrawerController? {
        get {
            return self.parent as? KYDrawerController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(prints), name: notificationDidEnterBackground, object: nil)
        
        menuTbl.dataSource = self
        menuTbl.delegate = self
        
        let logoGradient = GradientableOptions(colors: [UIColor.colorGreen, UIColor.colorAccent, UIColor.colorGreen], locations: nil, direction: GradientableOptionsDirection.bottomRightToTopLeft)
        logoView.set(options: logoGradient)
        
        let logo1 = GradientableOptions(colors: [UIColor.primary, UIColor.colorAccent, UIColor.primary], locations: nil, direction: GradientableOptionsDirection.bottomRightToTopLeft)
        
        titleView.set(options: logo1)
        
        menuList.append(MenuType(name: "My Videos", image: UIImage(named: "myvideo")))
        menuList.append(MenuType(name: "Uploaded Videos", image: UIImage(named: "uploaded")))
        menuList.append(MenuType(name: "Change Passcode", image: UIImage(named: "passcode")))
        menuList.append(MenuType(name: "Sign Out", image: UIImage(named: "logout")))
    }
    
    @objc func prints() {
        exit(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuList.count
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuCell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        let menuItem = menuList[indexPath.row]
        
        if let titleLabel = menuCell.viewWithTag(100) as? UILabel {
            titleLabel.text = menuItem.name
        }
        
        if let imageView = menuCell.viewWithTag(200) as? UIImageView {
            imageView.image = menuItem.image
        }
        
        return menuCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            drawer?.performSegue(withIdentifier: "Main", sender: nil)
            drawer?.setDrawerState(.closed, animated: true)
            break
        case 1:
            drawer?.performSegue(withIdentifier: "uploaded", sender: nil)
            drawer?.setDrawerState(.closed, animated: true)
            break
        case 2:
            UserDefaults.standard.set("0", forKey: kCodeStatus)
            drawer?.performSegue(withIdentifier: "Passcode", sender: nil)
            drawer?.setDrawerState(.closed, animated: true)
            break
        case 3:
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.set("", forKey: kUsername)
            UserDefaults.standard.synchronize()
            self.navigationController?.popToRootViewController(animated: true)
            break
        default:
            break
        }
    }
}

struct MenuType {
    var name: String
    var image: UIImage?
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }
}
