//
//  MenuViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/8/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(prints), name: notificationDidEnterBackground, object: nil)
    }
    
    @objc func prints() {
        exit(0)
    }
}
