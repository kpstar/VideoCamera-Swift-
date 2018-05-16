//
//  PlayerViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/14/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import AVKit

class PlayerViewController: AVPlayerViewController {

    
    var shareImg = UIImage(named: "share")
    var url: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player = AVPlayer(url: url!)
        self.player = player
        shareImg = shareImg?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: shareImg, style: .plain, target: self, action: #selector(shareVideo))
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.hidesBarsOnTap = false
    }
    
    @objc private func shareVideo() {
        let image = UIImage(named: "login_back")
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
