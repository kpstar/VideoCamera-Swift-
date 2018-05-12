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

class MenuViewController: UIViewController {

    @IBOutlet weak var logoView: GradientableView!
    @IBOutlet weak var menuTbl: UITableView!
    var menuList = [MenuType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(prints), name: notificationDidEnterBackground, object: nil)
        
        menuTbl.dataSource = self
        menuTbl.delegate = self
        
        let logoGradient = GradientableOptions(colors: [UIColor.primary, UIColor.colorAccent, UIColor.primary], locations: nil, direction: GradientableOptionsDirection.bottomRightToTopLeft)
        logoView.set(options: logoGradient)
        
        menuList.append(MenuType(name: "Change Passcode", image: UIImage(named: "login_icon")))
    }
    
    @objc func prints() {
        exit(0)
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
//            drawer?.performSegue(withIdentifier: "segueMain", sender: nil)
//            drawer?.setDrawerState(.closed, animated: true)
            break
        case 1:
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
