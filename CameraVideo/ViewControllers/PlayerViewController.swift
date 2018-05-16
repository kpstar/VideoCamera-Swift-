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
    //var videodata =
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player = AVPlayer(url: url!)
        //let playerLayer = AVPlayerLayer(player: player)
        
        self.player = player
//        playerLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(playerLayer)
        
        self.navigationController?.hidesBarsOnTap = true
        shareImg = shareImg?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: shareImg, style: .plain, target: self, action: #selector(shareVideo))
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc private func shareVideo() {
        let image = UIImage(named: "login_back")
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}
